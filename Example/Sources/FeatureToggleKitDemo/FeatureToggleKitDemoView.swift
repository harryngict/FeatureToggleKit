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

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Feature Toggle Bool: \(String(viewModel.testFeatureToggleBool))")
      Text("Feature Toggle Int: \(viewModel.testFeatureToggleInt)")
      Text("Feature Toggle Double: \(viewModel.testFeatureToggleDouble)")
      Text("Feature Toggle String: \(viewModel.testFeatureToggleString)")
      Text("Feature Toggle Json: \(viewModel.testFeatureToggleJSON)")
      Spacer()
    }
    .onAppear {
      viewModel.observeListenFeatureToggleUpdate()
    }
    .onDisappear {
      viewModel.removeListenFeatureToggleUpdate()
    }
  }

  // MARK: Private

  private let featureToggleKit: FeatureToggleKit
}
