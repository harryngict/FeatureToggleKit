
import Foundation

// MARK: - FeatureToggleKit

/// @mockable
public protocol FeatureToggleKit: AnyObject,
  FeatureToggleValueProviding,
  FeatureToggleExperimentManaging,
  FeatureToggleSetupManaging,
  FeatureToggleListenerManaging,
  FeatureToggleTweakCacheManaging,
  Sendable {}

public extension FeatureToggleKit {
  func getBoolValue(key: String) -> Bool {
    getBoolValue(key: key, fallbackValue: false)
  }

  func getStringValue(key: String) -> String {
    getStringValue(key: key, fallbackValue: "")
  }

  func getLongValue(key: String) -> Int64 {
    getLongValue(key: key, fallbackValue: 0)
  }

  func getDoubleValue(key: String) -> Double {
    getDoubleValue(key: key, fallbackValue: 0.0)
  }

  func getJSONValue(key: String) -> FeatureToggleDictionary {
    getJSONValue(key: key, fallbackValue: [:])
  }
}

/// @mockable
public protocol FeatureToggleValueProviding: AnyObject {
  func getBoolValue(key: String, fallbackValue: Bool) -> Bool
  func getStringValue(key: String, fallbackValue: String) -> String
  func getLongValue(key: String, fallbackValue: Int64) -> Int64
  func getDoubleValue(key: String, fallbackValue: Double) -> Double
  func getJSONValue(key: String, fallbackValue: FeatureToggleDictionary) -> FeatureToggleDictionary
}

/// @mockable
public protocol FeatureToggleExperimentManaging: AnyObject {
  func fetchAllFeatureToggles() -> FeatureToggleDictionary
  func resetAllFeatureToggles()
}

/// @mockable
public protocol FeatureToggleSetupManaging: AnyObject {
  func setup(definitionProviders: [FeatureToggleDefinitionProvider])
}

/// @mockable
public protocol FeatureToggleListenerManaging: AnyObject {
  func addListener(_ listener: FeatureToggleKitListener)
  func removeListener(_ listener: FeatureToggleKitListener)
  func addListeners(_ listeners: [FeatureToggleKitListener])
  func removeAllListeners()
}

/// @mockable
public protocol FeatureToggleTweakCacheManaging: AnyObject {
  func updateLocal(key: String, newValue: FeatureToggleValue) async
  func clearCache()
  func getFeatureToggleTweak(_ definition: FeatureToggleDefinition) -> FeatureToggleTweak?
}
