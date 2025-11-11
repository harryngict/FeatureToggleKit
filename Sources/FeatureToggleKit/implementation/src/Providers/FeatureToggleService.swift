import FeatureToggleKit
import Foundation

// MARK: - RemoteConfigService

/// @mockable
public protocol FeatureToggleService {
  func getFeatureToggleValue(_ definition: FeatureToggleDefinition) -> FeatureToggleValue?
  func addOnConfigUpdateListener(completion: @Sendable @escaping (Set<String>?, Error?) -> Void)
  func activateWithCompletion(completion: @escaping @Sendable (Bool, Error?) -> Void)
  func setDefaults(_ definition: FeatureToggleDefinition)
  func fetchAndActivate(completion: @Sendable @escaping () -> Void)
}
