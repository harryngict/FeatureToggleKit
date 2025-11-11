import Foundation

// MARK: - FeatureToggleAssertable

public protocol FeatureToggleAssertable {
  func assertRedefinedFeatureToggle(key: String)
  func assertUndefinedFeatureToggle(key: String)
  func assertTypeMismatchFeatureToggle(key: String)
}

// MARK: - FeatureToggleAssertableImp

public struct FeatureToggleAssertableImp: FeatureToggleAssertable {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func assertRedefinedFeatureToggle(key: String) {
    assertionFailure("FeatureToggleAssertable redefined: \(key)")
  }

  public func assertUndefinedFeatureToggle(key: String) {
    assertionFailure("FeatureToggleAssertable undefined: \(key)")
  }

  public func assertTypeMismatchFeatureToggle(key: String) {
    assertionFailure("FeatureToggleAssertable type mismatch: \(key)")
  }
}
