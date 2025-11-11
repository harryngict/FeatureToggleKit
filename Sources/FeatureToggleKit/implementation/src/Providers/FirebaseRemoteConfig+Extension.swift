import FeatureToggleKit
@preconcurrency import FirebaseRemoteConfig
import Foundation

// MARK: - RemoteConfig + FeatureToggleService

extension RemoteConfig: FeatureToggleService {
  public func setDefaults(_ definition: FeatureToggleDefinition) {
    switch definition.defaultValue {
    case .bool:
      if let bValue: Bool = definition.defaultValue.getValue() {
        try? setDefaults(from: [definition.key: bValue])
      }
    case .string:
      if let sValue: String = definition.defaultValue.getValue() {
        try? setDefaults(from: [definition.key: sValue])
      }
    case .long:
      if let int64Value: Int64 = definition.defaultValue.getValue() {
        try? setDefaults(from: [definition.key: int64Value])
      }
    case .double:
      if let dValue: Double = definition.defaultValue.getValue() {
        try? setDefaults(from: [definition.key: dValue])
      }
    case .json:
      if let json: FeatureToggleDictionary = definition.defaultValue.getValue() {
        try? setDefaults(from: [definition.key: json])
      }
    }
  }

  public func activateWithCompletion(completion: @escaping @Sendable (Bool, Error?) -> Void) {
    activate(completion: completion)
  }

  public func addOnConfigUpdateListener(completion: @Sendable @escaping (Set<String>?, Error?) -> Void) {
    addOnConfigUpdateListener { @Sendable configUpdate, error in
      completion(configUpdate?.updatedKeys, error)
    }
  }

  public func getFeatureToggleValue(_ definition: FeatureToggleDefinition) -> FeatureToggleValue? {
    let remoteValue = self[definition.key]
    guard remoteValue.source != .static else {
      return definition.defaultValue
    }

    switch definition.defaultValue {
    case .long:
      return .long(value: remoteValue.numberValue.int64Value)
    case .double:
      return .double(value: remoteValue.numberValue.doubleValue)
    case .bool:
      return .bool(value: remoteValue.boolValue)
    case .string:
      return .string(value: remoteValue.stringValue)
    case .json:
      guard let dict = remoteValue.jsonValue as? [String: Any] else {
        return .json(value: [:])
      }
      let featureToggleDict = dict.compactMapValues { mapToFeatureToggleValue($0) }
      return .json(value: featureToggleDict)
    }
  }

  public func fetchAndActivate(completion: @Sendable @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async { [weak self] in
      guard let self else {
        completion()
        return
      }
      self.fetchAndActivate { _, _ in
        completion()
      }
    }
  }
}

// MARK: Helper

private extension RemoteConfig {
  func mapToFeatureToggleValue(_ raw: Any) -> FeatureToggleValue? {
    if let number = raw as? NSNumber {
      let type = String(cString: number.objCType)
      switch type {
      case "c": // BOOL
        return .bool(value: number.boolValue)
      case "i", // integer types
           "l",
           "q",
           "s":
        return .long(value: number.int64Value)
      case "d", // double/float
           "f":
        return .double(value: number.doubleValue)
      default:
        return nil
      }
    }

    if let str = raw as? String {
      return .string(value: str)
    }

    if let nestedDict = raw as? [String: Any] {
      let nested = nestedDict.compactMapValues { mapToFeatureToggleValue($0) }
      return .json(value: nested)
    }

    if let array = raw as? [Any] {
      let dict = Dictionary(uniqueKeysWithValues: array.enumerated().map {
        (String($0.offset), mapToFeatureToggleValue($0.element) ?? .string(value: ""))
      })
      return .json(value: dict)
    }

    return nil
  }
}
