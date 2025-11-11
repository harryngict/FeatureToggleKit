import FeatureToggleKit
import Foundation

public protocol FeatureToggleKitSessionStorage {
  func saveFeatureToggleValue(forKey key: String, value: FeatureToggleValue) throws
  func hasValueChangedSinceLastCheck(forKey key: String) -> Bool
}
