import FeatureToggleKit

// MARK: - AppDependency

protocol AppDependency: AnyObject {
  var featureToggleKit: FeatureToggleKit { get }
}

// MARK: - AppDependencyImp

final class AppDependencyImp: AppDependency {
  // MARK: Lifecycle

  init(featureToggleKit: FeatureToggleKit) {
    self.featureToggleKit = featureToggleKit
  }

  // MARK: Internal

  let featureToggleKit: FeatureToggleKit
}
