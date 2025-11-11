import Foundation

// MARK: - FeatureToggleKitListener

/// @mockable
public protocol FeatureToggleKitListener: AnyObject, Sendable {
  func didReceiveFeatureToggleUpdates(values: [(String, FeatureToggleValue)]) async
  func didReceiveError(error: Error?) async
}

public extension FeatureToggleKitListener {
  func didReceiveError(error: Error?) async {}
}
