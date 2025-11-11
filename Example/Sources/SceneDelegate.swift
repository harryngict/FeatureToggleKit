import CoreLocation
import FeatureToggleKit
import FeatureToggleKitImp
import FirebaseCore
import SwiftUI

// MARK: - SceneDelegate

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // MARK: Internal

  var window: UIWindow?
  var featureToggleKit: FeatureToggleKit!

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions)
  {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)

    setupFirebaseApp()

    featureToggleKit = setupFeatureToggleKit(using: FeatureToggleProviderImp())

    let dependency = AppDependencyImp(featureToggleKit: featureToggleKit)

    displayContentView(for: window, with: dependency)
  }

  func sceneDidEnterBackground(_ scene: UIScene) {}

  // MARK: Private

  private func displayContentView(for window: UIWindow,
                                  with dependency: AppDependency)
  {
    let contentView = ContentView(dependency: dependency)
    window.rootViewController = UIHostingController(rootView: contentView)
    self.window = window
    window.makeKeyAndVisible()
  }

  private func setupFirebaseApp() {
    FirebaseApp.configure()
  }

  private func setupFeatureToggleKit(using provider: FeatureToggleProviderImp)
    -> FeatureToggleKit
  {
    let kit = FeatureToggleKitImp(
      featureToggleValueProvider: provider,
      tweakCacheService: TweakCacheServiceImp(cacheType: .both),
      requiresRemoteDefaultValues: true)
    kit.addListener(self)
    kit.setup(definitionProviders: [ExampleTeamAFeatureToggleDefinitionProvider()])
    kit.clearCache()
    return kit
  }
}

// MARK: FeatureToggleKitListener

extension SceneDelegate: FeatureToggleKitListener {
  func didReceiveError(error: (any Error)?) {
    print("\(error?.localizedDescription ?? "")")
  }

  func didReceiveFeatureToggleUpdates(values: [(String, FeatureToggleValue)]) {
    for (key, value) in values {
      print("key: \(key), value: \(value)")
    }
  }
}
