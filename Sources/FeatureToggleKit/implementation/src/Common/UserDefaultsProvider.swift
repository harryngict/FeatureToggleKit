import Foundation

// MARK: - UserDefaultsProvider

/// @mockable
public protocol UserDefaultsProvider: Sendable {
  func dictionary(forKey defaultName: String) -> [String: Any]?

  func set(_ value: Any?, forKey defaultName: String)

  func object(forKey defaultName: String) -> Any?

  func removeObject(forKey defaultName: String)

  func string(forKey defaultName: String) -> String?

  func array(forKey defaultName: String) -> [Any]?

  func data(forKey defaultName: String) -> Data?

  func stringArray(forKey defaultName: String) -> [String]?

  func integer(forKey defaultName: String) -> Int

  func float(forKey defaultName: String) -> Float

  func double(forKey defaultName: String) -> Double

  func bool(forKey defaultName: String) -> Bool

  func register(defaults registrationDictionary: [String: Any])

  func dictionaryRepresentation() -> [String: Any]

  @discardableResult
  func synchronize() -> Bool
}

// MARK: - UserDefaults + @unchecked @retroactive Sendable, UserDefaultsProvider

extension UserDefaults: @unchecked @retroactive Sendable, UserDefaultsProvider {}
