import Foundation

// MARK: - FeatureToggleDefinition

public struct FeatureToggleDefinition: Hashable, Sendable {
  // MARK: Lifecycle

  public init(key: String,
              defaultValue: FeatureToggleValue)
  {
    self.key = key
    self.defaultValue = defaultValue
  }

  // MARK: Public

  public let key: String
  public let defaultValue: FeatureToggleValue
}
