import FeatureToggleKit
import FirebaseRemoteConfig
import Foundation

// MARK: - FeatureToggleKitImp

public final class FeatureToggleKitImp: FeatureToggleKit, @unchecked Sendable {
  // MARK: Lifecycle

  public init(featureToggleValueProvider: FeatureToggleValueProvider,
              featureToggleAssertable: FeatureToggleAssertable = FeatureToggleAssertableImp(),
              tweakCacheService: TweakCacheService? = nil)
  {
    self.featureToggleValueProvider = featureToggleValueProvider
    self.featureToggleAssertable = featureToggleAssertable
    self.tweakCacheService = tweakCacheService
    self.featureToggleValueProvider.listener = self
  }

  // MARK: Public

  public func setup(definitionProviders: [FeatureToggleDefinitionProvider]) {
    let definitions: [FeatureToggleDefinition] = definitionProviders.flatMap(\.definitions)

    definitions.forEach { featureToggleValueProvider.setDefaultValue($0) }

    for definition in definitions {
      if let variant = featureToggleValueProvider.defineVariable(definition: definition) {
        if definedVariants[definition.key] != nil {
          featureToggleAssertable.assertUndefinedFeatureToggle(key: definition.key)
        }
        definedVariants[definition.key] = variant
      }
    }
  }

  public func fetchAllFeatureToggles() -> FeatureToggleDictionary {
    var result: FeatureToggleDictionary = [:]
    for (key, variant) in definedVariants {
      guard let value = getValue(for: key, variant: variant) else {
        continue
      }
      result[key] = value
    }
    return result
  }

  public func resetAllFeatureToggles() {
    featureToggleValueProvider.resetFeatureToggleValues { [weak self] in
      self?.syncFeatureToggleValues()
    }
  }

  // MARK: Private

  private var listeners: [FeatureToggleKitListener] = []
  private var definedVariants = DictionaryInThreadSafe<String, FeatureToggleVariant>()
  private var featureToggleValueProvider: FeatureToggleValueProvider
  private let featureToggleAssertable: FeatureToggleAssertable
  private var tweakCacheService: TweakCacheService?
}

// MARK: FeatureToggleValueProviderListener

extension FeatureToggleKitImp: FeatureToggleValueProviderListener {
  public func observeUpdateConfigFailed(error: Error?) async {
    for listener in listeners {
      await listener.didReceiveError(error: error)
    }
  }

  public func didReceiveUpdate(values: [(String, FeatureToggleValue)]) async {
    for (key, newValue) in values {
      guard definedVariants[key] != nil else {
        continue
      }
      definedVariants[key]?.value = newValue
    }
    for listener in listeners {
      await listener.didReceiveFeatureToggleUpdates(values: values)
    }
  }

  public func retrieveDefinition(key: String) -> FeatureToggleDefinition? {
    guard definedVariants[key] != nil else {
      return nil
    }
    return definedVariants[key]?.definition
  }
}

// MARK: Add/remove FeatureToggleKitListener

public extension FeatureToggleKitImp {
  func addListener(_ listener: FeatureToggleKitListener) {
    listeners.append(listener)
  }

  func removeListener(_ listener: FeatureToggleKitListener) {
    listeners.removeAll(where: { $0 === listener })
  }

  func addListeners(_ listeners: [FeatureToggleKitListener]) {
    self.listeners.append(contentsOf: listeners)
  }

  func removeAllListeners() {
    listeners = []
  }
}

// MARK: Get value

public extension FeatureToggleKitImp {
  func getBoolValue(key: String, fallbackValue: Bool) -> Bool {
    getValue(key: key) ?? fallbackValue
  }

  func getStringValue(key: String, fallbackValue: String) -> String {
    getValue(key: key) ?? fallbackValue
  }

  func getLongValue(key: String, fallbackValue: Int64) -> Int64 {
    getValue(key: key) ?? fallbackValue
  }

  func getDoubleValue(key: String, fallbackValue: Double) -> Double {
    getValue(key: key) ?? fallbackValue
  }

  func getJSONValue(key: String, fallbackValue: FeatureToggleDictionary) -> FeatureToggleDictionary {
    getValue(key: key) ?? fallbackValue
  }
}

// MARK: FeatureToggleTweakCacheManaging

extension FeatureToggleKitImp: FeatureToggleTweakCacheManaging {
  public func updateLocal(key: String, newValue: FeatureToggleValue) async {
    guard let variant = definedVariants[key] else {
      featureToggleAssertable.assertUndefinedFeatureToggle(key: key)
      return
    }
    guard var featureToggleTweak = getFeatureToggleTweak(variant.definition) else {
      return
    }
    featureToggleTweak.isEnabled = true
    featureToggleTweak.tweakedValue = newValue
    for listener in listeners {
      await listener.didReceiveFeatureToggleUpdates(values: [(key, newValue)])
    }
  }

  public func clearCache() {
    for (_, variant) in definedVariants {
      guard var featureToggleTweak = getFeatureToggleTweak(variant.definition) else {
        continue
      }
      featureToggleTweak.isEnabled = false
      featureToggleTweak.tweakedValue = variant.value
    }
  }

  public func getFeatureToggleTweak(_ definition: FeatureToggleDefinition) -> FeatureToggleTweak? {
    guard let tweakCacheService else {
      return nil
    }
    guard let originalValue = definedVariants[definition.key]?.value else {
      return nil
    }
    return FeatureToggleTweakImp(
      definition: definition,
      originalValue: originalValue,
      tweakCacheService: tweakCacheService,
      listeners: listeners)
  }
}

// MARK: Utilis

private extension FeatureToggleKitImp {
  func getValue<T>(key: String) -> T? {
    guard let variant = definedVariants[key] else {
      featureToggleAssertable.assertUndefinedFeatureToggle(key: key)
      return nil
    }

    if
      let featureToggleTweak = getFeatureToggleTweak(variant.definition),
      featureToggleTweak.isEnabled,
      let localValue: T = featureToggleTweak.tweakedValue.getValue()
    {
      return localValue
    }

    guard let remoteValue: T = variant.value.getValue() else {
      featureToggleAssertable.assertTypeMismatchFeatureToggle(key: key)
      return variant.definition.defaultValue.getValue()
    }

    return remoteValue
  }

  func getValue(for key: String, variant: FeatureToggleVariant) -> FeatureToggleValue? {
    switch variant.definition.defaultValue {
    case .bool: return getValue(key: key).map { FeatureToggleValue.bool(value: $0) }
    case .double: return getValue(key: key).map { FeatureToggleValue.double(value: $0) }
    case .long: return getValue(key: key).map { FeatureToggleValue.long(value: $0) }
    case .string: return getValue(key: key).map { FeatureToggleValue.string(value: $0) }
    case .json: return getValue(key: key).map { FeatureToggleValue.json(value: $0) }
    }
  }

  func syncFeatureToggleValues() {
    for (key, variant) in definedVariants {
      let definition = FeatureToggleDefinition(
        key: key,
        defaultValue: variant.value)
      if let variant = featureToggleValueProvider.defineVariable(definition: definition) {
        definedVariants[definition.key] = variant
      }
    }
  }
}
