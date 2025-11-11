import Foundation

public protocol FeatureToggleTweak: Sendable {
  var definition: FeatureToggleDefinition { get }
  var isEnabled: Bool { get set }
  var originalValue: FeatureToggleValue { get }
  var tweakedValue: FeatureToggleValue { get set }
}
