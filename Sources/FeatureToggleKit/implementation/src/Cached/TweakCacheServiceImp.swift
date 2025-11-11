import FeatureToggleKit
import Foundation

// MARK: - TweakCacheServiceImp

public final class TweakCacheServiceImp: TweakCacheService {
  // MARK: Lifecycle

  public init(cacheType: TweakCacheServiceType,
              userDefaultsProvider: UserDefaultsProvider = UserDefaults.standard)
  {
    self.cacheType = cacheType
    self.userDefaultsProvider = userDefaultsProvider
  }

  // MARK: Public

  public let cacheType: TweakCacheServiceType

  public func getCacheData(key: String) -> FeatureToggleValue? {
    switch cacheType {
    case .memory:
      return inmemoryDict[key]
    case .persistent:
      return getPersistentData(key: key)
    case .both:
      if let inMemoryValue = inmemoryDict[key] {
        return inMemoryValue
      } else {
        let persistentValue = getPersistentData(key: key)
        if let value = persistentValue {
          inmemoryDict[key] = value
        }
        return persistentValue
      }
    }
  }

  public func saveCacheData(key: String, value: FeatureToggleValue) throws {
    switch cacheType {
    case .memory:
      inmemoryDict[key] = value
    case .persistent:
      try savePersistentData(key: key, value: value)
    case .both:
      inmemoryDict[key] = value
      try savePersistentData(key: key, value: value)
    }
  }

  public func clear() {
    switch cacheType {
    case .memory:
      inmemoryDict.removeAll()
    case .persistent:
      clearPersistentData()
    case .both:
      inmemoryDict.removeAll()
      clearPersistentData()
    }
  }

  public func isCacheEmpty() -> Bool {
    switch cacheType {
    case .memory:
      return inmemoryDict.isEmpty
    case .persistent:
      return persistentDict?.isEmpty ?? true
    case .both:
      return inmemoryDict.isEmpty && (persistentDict?.isEmpty ?? true)
    }
  }

  // MARK: Private

  private enum Constants {
    static let userdefaultsKey = "tweakCacheServiceImp_userdefaultsKey"
  }

  private let userDefaultsProvider: UserDefaultsProvider
  private var inmemoryDict = DictionaryInThreadSafe<String, FeatureToggleValue>()

  private var persistentDict: [String: Data]? {
    get {
      userDefaultsProvider.dictionary(forKey: Constants.userdefaultsKey) as? [String: Data]
    }
    set {
      userDefaultsProvider.set(newValue, forKey: Constants.userdefaultsKey)
      _ = userDefaultsProvider.synchronize()
    }
  }

  private func getPersistentData(key: String) -> FeatureToggleValue? {
    guard let encodedData = persistentDict?[key] else {
      return nil
    }
    return try? JSONDecoder().decode(FeatureToggleValue.self, from: encodedData)
  }

  private func savePersistentData(key: String, value: FeatureToggleValue) throws {
    do {
      let encodedData = try JSONEncoder().encode(value)
      var dictionary = persistentDict ?? [String: Data]()
      dictionary[key] = encodedData
      persistentDict = dictionary
    } catch {
      throw error
    }
  }

  private func clearPersistentData() {
    persistentDict = nil
  }
}
