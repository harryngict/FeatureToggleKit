import SwiftUI

// MARK: - ContentView

struct ContentView: View {
  // MARK: Lifecycle

  init(dependency: AppDependency) {
    self.dependency = dependency
  }

  // MARK: Internal

  var body: some View {
    NavigationView {
      List {
        NavigationLink(
          destination: FeatureToggleKitDemoView(
            featureToggleKit: dependency.featureToggleKit)
        ) {
          Text("Tap to open FeatureToggleKitDemoView")
        }
      }
      .navigationTitle("Demo")
    }
  }

  // MARK: Private

  private let dependency: AppDependency
}
