import FeatureToggleKit
import Foundation

// MARK: - ExampleTeamAFeatureToggleDefinition

enum ExampleTeamAFeatureToggleDefinition: String, CaseIterable {
  case testFeatureToggleBool = "test_bool_enabled"
  case testFeatureToggleInt = "test_int_value"
  case testFeatureToggleDouble = "test_double_value"
  case testFeatureToggleString = "test_string_value"
  case testFeatureToggleJSON = "test_json_value"

  // MARK: Internal

  var defaultValue: FeatureToggleValue {
    switch self {
    case .testFeatureToggleBool: return false
    case .testFeatureToggleInt: return 0
    case .testFeatureToggleDouble: return 0.0
    case .testFeatureToggleString: return ""
    case .testFeatureToggleJSON: return .json(value: [:])
    }
  }
}

// MARK: - ExampleTeamAFeatureToggleDefinitionProvider

struct ExampleTeamAFeatureToggleDefinitionProvider: FeatureToggleDefinitionProvider {
  // MARK: Lifecycle

  init() {}

  // MARK: Internal

  let name = "Platform Team"

  var definitions: [FeatureToggleDefinition] {
    ExampleTeamAFeatureToggleDefinition.allCases.map { definition in
      FeatureToggleDefinition(
        key: definition.rawValue,
        defaultValue: definition.defaultValue)
    }
  }
}
