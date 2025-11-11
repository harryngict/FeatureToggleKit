import FeatureToggleKit
import Foundation

public struct FeatureToggleVariantImp: FeatureToggleVariant {
  // MARK: Lifecycle

  public init(definition: FeatureToggleDefinition,
              value: FeatureToggleValue)
  {
    self.definition = definition
    self.value = value
  }

  // MARK: Public

  public let definition: FeatureToggleDefinition
  public var value: FeatureToggleValue
}
