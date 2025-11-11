import FeatureToggleKit
import Foundation

// MARK: - FeatureToggleKitDemoViewModel

final class FeatureToggleKitDemoViewModel {
  // MARK: Lifecycle

  init(featureToggleKit: FeatureToggleKit) {
    self.featureToggleKit = featureToggleKit
  }

  // MARK: Internal

  var testFeatureToggleBool: Bool {
    featureToggleKit.getBoolValue(
      key: ExampleTeamAFeatureToggleDefinition.testFeatureToggleBool.rawValue)
  }

  var testFeatureToggleInt: Int64 {
    featureToggleKit.getLongValue(
      key: ExampleTeamAFeatureToggleDefinition.testFeatureToggleInt.rawValue)
  }

  var testFeatureToggleDouble: Double {
    featureToggleKit.getDoubleValue(
      key: ExampleTeamAFeatureToggleDefinition.testFeatureToggleDouble.rawValue)
  }

  var testFeatureToggleString: String {
    featureToggleKit.getStringValue(
      key: ExampleTeamAFeatureToggleDefinition.testFeatureToggleString.rawValue)
  }

  var testFeatureToggleJSON: String {
    let value = featureToggleKit.getJSONValue(key: ExampleTeamAFeatureToggleDefinition.testFeatureToggleJSON.rawValue)
    if let config: TestJSONConfig = value.toModel(to: TestJSONConfig.self) {
      print(config)
    } else {
      print("Failed to decode")
    }
    return value.primitiveJSON()
  }

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
