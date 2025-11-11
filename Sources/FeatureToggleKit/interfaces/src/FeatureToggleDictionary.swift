import Foundation

// MARK: - FeatureToggleDictionaryError

public enum FeatureToggleDictionaryError: LocalizedError {
  case invalidEncoding
  case notADictionary
  case invalidJSON(Error)

  // MARK: Public

  public var errorDescription: String {
    switch self {
    case .invalidEncoding:
      return "The text is not valid UTF-8. Please check for special characters."
    case .notADictionary:
      return "The root of the JSON must be an object (e.g. { \"key\": value })."
    case let .invalidJSON(error):
      return "Invalid JSON format: \(error.localizedDescription)"
    }
  }
}

public typealias FeatureToggleDictionary = [String: FeatureToggleValue]

public extension FeatureToggleDictionary {
  func primitiveJSON(pretty: Bool = true) -> String {
    let primitive = mapValues { $0.asPrimitiveValue() }
    guard
      let data = try? JSONSerialization.data(
        withJSONObject: primitive,
        options: pretty ? [.prettyPrinted, .sortedKeys] : []) else
    {
      return "{}"
    }
    return String(data: data, encoding: .utf8) ?? "{}"
  }

  func toModel<T: Decodable>(to type: T.Type, options opt: JSONSerialization.WritingOptions = []) -> T? {
    do {
      let primitiveDict = mapValues { $0.asPrimitiveValue() }
      let data = try JSONSerialization.data(withJSONObject: primitiveDict, options: opt)
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      return nil
    }
  }

  static func fromJSONString(_ json: String) throws -> FeatureToggleDictionary {
    guard let data = json.data(using: .utf8) else {
      throw FeatureToggleDictionaryError.invalidEncoding
    }

    do {
      let obj = try JSONSerialization.jsonObject(with: data, options: [])
      guard let dict = obj as? [String: Any] else {
        throw FeatureToggleDictionaryError.notADictionary
      }
      return dict.mapValues { FeatureToggleValue.from(primitive: $0) }
    } catch {
      throw FeatureToggleDictionaryError.invalidJSON(error)
    }
  }
}
