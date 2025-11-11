import FeatureToggleKit
import Foundation

// MARK: - FeatureToggleValueProvider

/// @mockable
public protocol FeatureToggleValueProvider: AnyObject, Sendable {
  var name: String { get }
  var listener: FeatureToggleValueProviderListener? { get set }

  func setDefaultValue(_ definition: FeatureToggleDefinition)
  func defineVariable(definition: FeatureToggleDefinition) -> FeatureToggleVariant?
  func resetFeatureToggleValues(completion: @Sendable @escaping () -> Void)
}

// MARK: - FeatureToggleValueProviderListener

/// @mockable
public protocol FeatureToggleValueProviderListener: AnyObject {
  func observeUpdateConfigFailed(error: Error?) async
  func didReceiveUpdate(values: [(String, FeatureToggleValue)]) async
  func retrieveDefinition(key: String) -> FeatureToggleDefinition?
}
