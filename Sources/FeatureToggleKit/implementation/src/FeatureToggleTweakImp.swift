import FeatureToggleKit
import Foundation

public final class FeatureToggleTweakImp: FeatureToggleTweak, @unchecked Sendable {
  // MARK: Lifecycle

  init(definition: FeatureToggleDefinition,
       originalValue: FeatureToggleValue,
       tweakCacheService: TweakCacheService,
       userDefaults: UserDefaultsProvider = UserDefaults.standard,
       listeners: [FeatureToggleKitListener])
  {
    self.definition = definition
    self.originalValue = originalValue
    self.tweakCacheService = tweakCacheService
    self.userDefaults = userDefaults
    self.listeners = listeners
  }

  // MARK: Public

  public var definition: FeatureToggleDefinition
  public var originalValue: FeatureToggleValue

  public var tweakedValue: FeatureToggleValue {
    get {
      tweakCacheService.getCacheData(key: definition.key) ?? originalValue
    }
    set {
      try? tweakCacheService.saveCacheData(key: definition.key, value: newValue)
      Task { [weak self] in
        guard let self else { return }
        for listener in listeners {
          await listener.didReceiveFeatureToggleUpdates(values: [(definition.key, newValue)])
        }
      }
    }
  }

  public var isEnabled: Bool {
    get {
      userDefaults.object(forKey: isEnabledKey) as? Bool ?? false
    }
    set {
      userDefaults.set(newValue, forKey: isEnabledKey)
    }
  }

  // MARK: Private

  private let userDefaults: UserDefaultsProvider
  private let tweakCacheService: TweakCacheService
  private var listeners: [FeatureToggleKitListener]

  private var isEnabledKey: String {
    definition.key + "_isEnabled.tweak"
  }
}
