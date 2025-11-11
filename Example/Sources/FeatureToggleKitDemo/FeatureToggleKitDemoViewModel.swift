import FeatureToggleKit
import Foundation

// MARK: - FeatureToggleKitDemoViewModel

final class FeatureToggleKitDemoViewModel {
  // MARK: Lifecycle

  init(featureToggleKit: FeatureToggleKit) {
    self.featureToggleKit = featureToggleKit
  }

  // MARK: Internal

  func observeListenFeatureToggleUpdate() {
    featureToggleKit.addListener(self)
  }

  func removeListenFeatureToggleUpdate() {
    featureToggleKit.removeListener(self)
  }

  // MARK: Private

  private let featureToggleKit: FeatureToggleKit
}

// MARK: FeatureToggleKitListener

extension FeatureToggleKitDemoViewModel: FeatureToggleKitListener {
  func didReceiveError(error: (any Error)?) {
    print("\(error?.localizedDescription ?? "")")
  }

  func didReceiveFeatureToggleUpdates(values: [(String, FeatureToggleValue)]) {
    for (key, value) in values {
      print("key: \(key), value: \(value)")
    }
  }
}
