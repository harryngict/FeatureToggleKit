import FeatureToggleKit
import FirebaseRemoteConfig
import Foundation

// MARK: - FeatureToggleProviderImp

public final class FeatureToggleProviderImp: FeatureToggleValueProvider, @unchecked Sendable {
  // MARK: Lifecycle

  public init(remoteConfigService: RemoteConfigService = RemoteConfig.remoteConfig()) {
    self.remoteConfigService = remoteConfigService
    listenerUpdate()
  }

  // MARK: Public

  public let name = "FeatureToggleProviderImp"
  public weak var listener: FeatureToggleValueProviderListener?

  public func defineVariable(definition: FeatureToggleDefinition) -> FeatureToggleVariant? {
    guard let value = remoteConfigService.getFeatureToggleValue(definition) else {
      return nil
    }
    return FeatureToggleVariantImp(definition: definition, value: value)
  }

  public func setDefaultValue(_ definition: FeatureToggleDefinition) {
    remoteConfigService.setDefaults(definition)
  }

  public func resetFeatureToggleValues(completion: @Sendable @escaping () -> Void) {
    remoteConfigService.fetchAndActivate(completion: completion)
  }

  // MARK: Private

  private let remoteConfigService: RemoteConfigService
}

extension FeatureToggleProviderImp {
  func listenerUpdate() {
    remoteConfigService.addOnConfigUpdateListener { [weak self] updatedKeys, error in
      guard let updatedKeys, error == nil else {
        self?.handleConfigUpdateError(error)
        return
      }
      self?.handleConfigUpdateSuccess(updatedKeys)
    }
  }

  // MARK: - Private helpers

  private func handleConfigUpdateError(_ error: Error?) {
    Task { [weak self] in
      await self?.listener?.observeUpdateConfigFailed(error: error)
    }
  }

  private func handleConfigUpdateSuccess(_ updatedKeys: Set<String>) {
    remoteConfigService.activateWithCompletion { _, _ in
      var values: [(String, FeatureToggleValue)] = []
      for key in updatedKeys {
        guard let defination = self.listener?.retrieveDefinition(key: key) else {
          continue
        }
        guard let value = self.remoteConfigService.getFeatureToggleValue(defination) else {
          continue
        }
        values.append((key, value))
      }
      guard !values.isEmpty else { return }
      Task { [weak self] in
        await self?.listener?.didReceiveUpdate(values: values)
      }
    }
  }
}
