import FeatureToggleKit
import Foundation

// MARK: - TweakCacheService

/// @mockable
public protocol TweakCacheService: AnyObject {
  var cacheType: TweakCacheServiceType { get }
  func getCacheData(key: String) -> FeatureToggleValue?
  func saveCacheData(key: String, value: FeatureToggleValue) throws
  func clear()
  func isCacheEmpty() -> Bool
}
