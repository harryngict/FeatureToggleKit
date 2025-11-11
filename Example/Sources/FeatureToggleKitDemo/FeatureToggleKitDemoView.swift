import FeatureToggleKit
import SwiftUI

struct FeatureToggleKitDemoView: View {
  // MARK: Lifecycle

  init(featureToggleKit: FeatureToggleKit) {
    viewModel = FeatureToggleKitDemoViewModel(featureToggleKit: featureToggleKit)
    self.featureToggleKit = featureToggleKit
  }

  // MARK: Internal

  let viewModel: FeatureToggleKitDemoViewModel

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

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Feature Toggle Bool: \(String(testFeatureToggleBool))")
      Text("Feature Toggle Int: \(testFeatureToggleInt)")
      Text("Feature Toggle Double: \(testFeatureToggleDouble)")
      Text("Feature Toggle String: \(testFeatureToggleString)")
      Text("Feature Toggle Json: \(testFeatureToggleJSON)")
      Spacer()
    }
    .onAppear {
      viewModel.observeListenFeatureToggleUpdate()
      for (key, value) in featureToggleKit.fetchAllFeatureToggles() {
        print("key: \(key), value: \(value)")
      }
    }
    .onDisappear {
      viewModel.removeListenFeatureToggleUpdate()
    }
  }

  // MARK: Private

  private let featureToggleKit: FeatureToggleKit
}
