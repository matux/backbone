import struct Foundation.TimeZone
import struct Foundation.Date
import class Foundation.ByteCountFormatter
import class Foundation.NumberFormatter
import class Foundation.DateFormatter
import class Foundation.NSDecimalNumber

public class FileSizeFormatter: ByteCountFormatter {

  static func format(_ size: Int) -> String {
    return FileSizeFormatter()
      => \.countStyle ~ .file
      => \.allowedUnits ~ [.useBytes, .useKB, .useMB, .useGB]
      => flip(ByteCountFormatter.string)(.init(size))
  }
}

public class DecimalFormatter: NumberFormatter {

  @inlinable
  public static func format<T: BinaryFloatingPoint>(
    decimals: Int, _ n: T
  ) -> String {
    return DecimalFormatter(digits: decimals).format(.init(n))
  }

  @inlinable
  public static func format<T: BinaryFloatingPoint>(_ n: T) -> String {
    return format(decimals: 2, n)
  }

  public convenience init(digits: Int = 2) {
    self.init()
    numberStyle = .decimal
    roundingMode = .halfEven
    generatesDecimalNumbers = true
    usesSignificantDigits = false
    minimumFractionDigits = 0
    maximumFractionDigits = digits
  }

  @inlinable
  public func format(_ number: Double) -> String {
    return string(from: NSDecimalNumber(value: number))
      .map { $0 == "-0" ? "0" : $0 } ?? nilSymbol
  }
}

extension DateFormatter {

  @inlinable
  public convenience init(
    format: String,
    timeZone: TimeZone? = .none
  ) {
    self.init()
    self.dateFormat = format
    self.timeZone = timeZone
  }
}

extension String {

  @inlinable
  public init(_ date: Date) {
    self = DateFormatter.localizedString(
      from: date,
      dateStyle: .medium,
      timeStyle: .medium)
  }
}
