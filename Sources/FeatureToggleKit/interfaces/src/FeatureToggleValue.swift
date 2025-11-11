import Foundation

// MARK: - FeatureToggleValue

@frozen
public enum FeatureToggleValue: Codable, Hashable, Sendable {
  /// Represents a boolean value.
  case bool(value: Bool)

  /// Represents a string value.
  case string(value: String)

  /// Represents a long (Int64) value.
  case long(value: Int64)

  /// Represents a double value.
  case double(value: Double)

  /// Represents a JSON dictionary of nested FeatureToggleValue.
  case json(value: FeatureToggleDictionary)

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    if let value = try? values.decode(FeatureToggleDictionary.self, forKey: .json) {
      self = .json(value: value)
      return
    }

    if let value = try? values.decode(Bool.self, forKey: .bool) {
      self = .bool(value: value)
      return
    }
    if let value = try? values.decode(String.self, forKey: .string) {
      self = .string(value: value)
      return
    }
    if let value = try? values.decode(Int64.self, forKey: .long) {
      self = .long(value: value)
      return
    }
    if let value = try? values.decode(Double.self, forKey: .double) {
      self = .double(value: value)
      return
    }

    throw FeatureToggleValueCodingError.decoding("Decode FeatureToggleValue failed. \(dump(values))")
  }

  // MARK: Public

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .bool(value): try container.encode(value, forKey: .bool)
    case let .string(value): try container.encode(value, forKey: .string)
    case let .long(value): try container.encode(value, forKey: .long)
    case let .double(value): try container.encode(value, forKey: .double)
    case let .json(value): try container.encode(value, forKey: .json)
    }
  }

  public func getValue<T>() -> T? {
    switch self {
    case let .bool(value): return value as? T
    case let .string(value): return value as? T
    case let .long(value): return value as? T
    case let .double(value): return value as? T
    case let .json(value): return value as? T
    }
  }

  public func asPrimitiveValue() -> Any {
    switch self {
    case let .bool(value): return value
    case let .long(value): return Int(value)
    case let .double(value): return value
    case let .string(value): return value
    case let .json(dict):
      let keys = dict.keys.compactMap { Int($0) }.sorted()
      if keys.count == dict.count, keys.first == 0, keys.last == dict.count - 1 {
        return keys.compactMap { key in
          dict[String(key)]?.asPrimitiveValue()
        }
      } else {
        return dict.mapValues { $0.asPrimitiveValue() }
      }
    }
  }

  // MARK: Internal

  enum FeatureToggleValueCodingError: Error {
    case decoding(String)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case bool
    case string
    case long
    case double
    case json
  }
}

// MARK: ExpressibleByBooleanLiteral

extension FeatureToggleValue: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .bool(value: value)
  }
}

// MARK: ExpressibleByStringLiteral

extension FeatureToggleValue: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value: value)
  }
}

// MARK: ExpressibleByIntegerLiteral

extension FeatureToggleValue: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self = .long(value: Int64(value))
  }
}

// MARK: ExpressibleByFloatLiteral

extension FeatureToggleValue: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self = .double(value: value)
  }
}

public extension FeatureToggleValue {
  static func from(primitive: Any) -> FeatureToggleValue {
    switch primitive {
    case let bool as Bool: return .bool(value: bool)
    case let int as Int: return .long(value: Int64(int))
    case let int64 as Int64: return .long(value: int64)
    case let double as Double: return .double(value: double)
    case let string as String: return .string(value: string)
    case let dict as [String: Any]:
      let nestedDict = dict.mapValues { FeatureToggleValue.from(primitive: $0) }
      return .json(value: nestedDict)
    case let array as [Any]:
      let dict = Dictionary(uniqueKeysWithValues: array.enumerated().map { (String($0.offset), FeatureToggleValue.from(primitive: $0.element)) })
      return .json(value: dict)
    default:
      return .string(value: "\(primitive)")
    }
  }
}
