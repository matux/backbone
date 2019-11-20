import Swift

/// Represents a source location in a Swift file.
public struct SourceLoc: Hashable {

  /// The file in which this location resides.
  public let file: StaticString

  /// The file in which this location resides.
  public let function: StaticString

  /// The line in the file where this location resides.
  public let line: Int

  /// The UTF-8 byte offset from the start of the line.
  public let column: Int

  public init(fl: StaticString, fn: StaticString, ln: Int, col: Int) {
    (file, function, line, column) = (fl, fn, ln, col)
  }
}
