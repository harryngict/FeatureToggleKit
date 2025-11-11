import Foundation

struct TestJSONConfig: Decodable {
  let stringFiled: String
  let intField: Int
  let doubleField: Double
  let boolField: Bool
  let ints: [Int]
  let strings: [String]
  let doubles: [Double]
  let bools: [Bool]
}
