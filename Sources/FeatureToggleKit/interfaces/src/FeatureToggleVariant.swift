/// @mockable
public protocol FeatureToggleVariant: Sendable {
  var definition: FeatureToggleDefinition { get }
  var value: FeatureToggleValue { get set }
}
