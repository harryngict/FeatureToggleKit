import Foundation

// MARK: - FeatureToggleDefinitionProvider

/// @mockable
public protocol FeatureToggleDefinitionProvider: Sendable {
  var name: String { get }
  var definitions: [FeatureToggleDefinition] { get }
}
