import class Foundation.NSNumber

extension NSNumber: Comparable {

  public static func < (x: NSNumber, y: NSNumber) -> Bool {
    x.compare(y) == .orderedAscending
  }

  public static func < (x: NSNumber, y: Double) -> Bool {
    x.compare(NSNumber(value: y)) == .orderedAscending
  }

  public static func < (x: Double, y: NSNumber) -> Bool {
    NSNumber(value: x).compare(y) == .orderedAscending
  }

  public static func < (x: NSNumber, y: Int) -> Bool {
    x.compare(NSNumber(value: y)) == .orderedAscending
  }

  public static func < (x: Int, y: NSNumber) -> Bool {
    NSNumber(value: x).compare(y) == .orderedAscending
  }
}

