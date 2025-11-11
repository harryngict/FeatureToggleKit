import FeatureToggleKit
import Foundation

public final class FeatureToggleKitSessionStorageImp: FeatureToggleKitSessionStorage {
  // MARK: Lifecycle

  public init(userDefaultsProvider: UserDefaultsProvider = UserDefaults.standard) {
    self.userDefaultsProvider = userDefaultsProvider

    if let storedDict = userDefaultsProvider.dictionary(forKey: Constants.userdefaultsKey) as? [String: Data] {
      for (key, value) in storedDict {
        persistentDict[key] = value
      }
    }

    if let storedStatus = userDefaultsProvider.dictionary(forKey: Constants.statusKey) as? [String: Bool] {
      for (key, value) in storedStatus {
        featureToggleStatus[key] = value
      }
    }
  }

  // MARK: Public

  public func saveFeatureToggleValue(forKey key: String, value: FeatureToggleValue) throws {
    let newValueData = try JSONEncoder().encode(value)
    let currentValueData = persistentDict[key]
    let hasChanged = currentValueData != newValueData

    featureToggleStatus[key] = hasChanged
    persistentDict[key] = newValueData
    persistToUserDefaults()
  }

  public func hasValueChangedSinceLastCheck(forKey key: String) -> Bool {
    featureToggleStatus[key] ?? true
  }

  // MARK: Private

  private enum Constants {
    static let userdefaultsKey = "FeatureToggleKitSessionStorageImp_userdefaultsKey"
    static let statusKey = "FeatureToggleKitSessionStorageImp_statusKey"
  }

  private let userDefaultsProvider: UserDefaultsProvider
  private let featureToggleStatus = DictionaryInThreadSafe<String, Bool>()
  private let persistentDict = DictionaryInThreadSafe<String, Data>()

  private func persistToUserDefaults() {
    let rawStatus = featureToggleStatus.keys.reduce(into: [String: Bool]()) { result, key in
      if let value = featureToggleStatus[key] {
        result[key] = value
      }
    }

    let rawDict = persistentDict.keys.reduce(into: [String: Data]()) { result, key in
      if let value = persistentDict[key] {
        result[key] = value
      }
    }

    userDefaultsProvider.set(rawStatus, forKey: Constants.statusKey)
    userDefaultsProvider.set(rawDict, forKey: Constants.userdefaultsKey)
    _ = userDefaultsProvider.synchronize()
  }
}
