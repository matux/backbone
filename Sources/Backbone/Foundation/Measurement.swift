import class Foundation.UnitConverter
import class Foundation.UnitConverterLinear
import struct Foundation.Measurement

@available(OSX 10.12, *)
extension UnitConverter {

  public class func linear(
    coefficient: Double,
    const: Double = 0
  ) -> UnitConverter {
    UnitConverterLinear(
      coefficient: coefficient,
      constant: const)
  }
}

// MARK: - Measurement

/// A numerical quantity in terms of a unit of measurement.
///
///  quantifiable by measure constrained to a unit of a dimension
/// , with support for unit
/// conversion and unit-aware calculations.
public typealias Measurement<Unit: UnitOfMeasurement> = Newtype<Double, Unit>

//extension Newtype where RawValue == Double, Tag: UnitOfMeasurement {
extension Measurement where Derived == Double, Tag: UnitOfMeasurement {
  public typealias Unit = Tag

  @available(OSX 10.12, *)
  public func converted<ConvertedUnit: UnitOfMeasurement>(
    to _: ConvertedUnit.Type
  ) -> Measurement<ConvertedUnit>
    where ConvertedUnit.Dimension == Unit.Dimension
  {
    let source = Unit.converter.baseUnitValue(fromValue: rawValue)
    let target = ConvertedUnit.converter.value(fromBaseUnitValue: source)
    return .init(target)
  }

  /// Returns the measurement value as its native type.
  public static prefix func * (_ measurement: Self) -> RawValue {
    measurement.rawValue
  }
}

extension Measurement: CustomStringConvertible
  where Derived == Double, Tag: UnitOfMeasurement
{
  public var description: String { "\(rawValue) \(Unit.symbol)" }
}

extension Measurement: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral
  where Derived == Double, Tag: UnitOfMeasurement
{
  public init(integerLiteral value: IntegerLiteralType) {
    rawValue = Derived(value)
  }

  public init(floatLiteral value: FloatLiteralType) {
    rawValue = value
  }
}

// MARK: -
// MARK: - Units

/// The type of values that represent a quantitative property relative to a
/// unit of measurement.
public protocol Quantitative {

  /// The base unit of measurement by which the magnitude of a quantity can be
  /// determined.
  associatedtype BaseUnit: UnitOfMeasurement
}

/// A definite magnitude of a quantity used as a standard for measurement of the
/// same kind of quantity or multiple of the unit of measurement.
public protocol UnitOfMeasurement {
  /// The kind of unit.
  associatedtype Dimension: Quantitative

  /// The unit's symbol as defined by the International System of Units.
  static var symbol: String { get }

  /// An instance capable of converting a unit to and from the base unit of its
  /// dimension.
  @available(OSX 10.12, *)
  static var converter: UnitConverter { get }
}

/// MARK: -

/// The quantitative property of length.
public enum Length: Quantitative {
  public typealias BaseUnit = Meters
}

public enum Meters: UnitOfMeasurement {
  public typealias Dimension = Length

  @available(OSX 10.12, *)
  public static let converter: UnitConverter = .linear(coefficient: 1)
  public static let symbol = "m"
}

public enum Kilometers: UnitOfMeasurement {
  public typealias Dimension = Length

  @available(OSX 10.12, *)
  public static let converter: UnitConverter = .linear(coefficient: 1000)
  public static let symbol = "km"
}

// MARK: -

/// The quantitative property of time.
public enum Time: Quantitative {
  public typealias BaseUnit = Seconds
}

public enum Milliseconds: UnitOfMeasurement {
  public typealias Dimension = Time

  public static let symbol = "ms"
  @available(OSX 10.12, *)
  public static let converter: UnitConverter = .linear(coefficient: 0.001)
}

public enum Seconds: UnitOfMeasurement {
  public typealias Dimension = Time

  @available(OSX 10.12, *)
  public static let converter: UnitConverter = .linear(coefficient: 1)
  public static let symbol = "sec"
}

public enum Minutes: UnitOfMeasurement {
  public typealias Dimension = Time

  @available(OSX 10.12, *)
  public static let converter: UnitConverter = .linear(coefficient: 60)
  public static let symbol = "min"
}

public enum Hours: UnitOfMeasurement {
  public typealias Dimension = Time

  @available(OSX 10.12, *)
  public static let converter: UnitConverter = .linear(coefficient: 60 * 24)
  public static let symbol = "hr"
}

extension Measurement where Derived == Double, Tag: UnitOfMeasurement, Tag.Dimension == Time {
  public static var second: Measurement<Seconds> { return .seconds(1) }
  public static var minute: Measurement<Minutes> { return .minutes(1) }
  public static var hour: Measurement<Hours> { return .hours(1) }

  public static func seconds(_ x: RawValue) -> Measurement<Seconds> {
    .init(x)
  }

  public static func minutes(_ x: RawValue) -> Measurement<Minutes> {
    .init(x)
  }

  public static func hours(_ x: RawValue) -> Measurement<Hours> {
    .init(x)
  }
}


// MARK: -

/// The quantitative property of speed.
public enum Speed: Quantitative {
  public typealias BaseUnit = MetersPerSecond
}

public enum MetersPerSecond: UnitOfMeasurement {
  public typealias Dimension = Speed

  @available(OSX 10.12, *)
  public static let converter: UnitConverter = .linear(coefficient: 1)
  public static let symbol = "m/s"
}

public enum KilometersPerHour: UnitOfMeasurement {
  public typealias Dimension = Speed

  @available(OSX 10.12, *)
  public static let converter: UnitConverter = .linear(coefficient: 1 / 3.6)
  public static let symbol = "km/h"
}

// MARK: -
// MARK: -

extension Double {

  public var secs: Measurement<Seconds> { .init(self) }
  public var sec: Measurement<Seconds> { .init(self) }
  public var mins: Measurement<Minutes> { .init(self) }
  public var min: Measurement<Minutes> { .init(self) }
  public var hrs: Measurement<Hours> { .init(self) }
  public var hr: Measurement<Hours> { .init(self) }

  public var meters: Measurement<Meters> { .init(self) }
  public var meter: Measurement<Meters> { .init(self) }
  public var kms: Measurement<Kilometers> { .init(self) }
  public var km: Measurement<Kilometers> { .init(self) }

  public var mps: Measurement<MetersPerSecond> { .init(self) }
  public var kph: Measurement<KilometersPerHour> { .init(self) }
}
