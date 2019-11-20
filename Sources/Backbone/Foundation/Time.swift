import struct Foundation.TimeInterval

#if canImport(QuartzCore)
import class QuartzCore.CATransaction

extension TimeInterval {
  /// Standard Core Animation duration (0.25s|250ms)
  public static let `default` = CATransaction.animationDuration() // 0.250s
}

#else

extension TimeInterval {
  /// Standard iOS animation duration (0.25s|250ms)
  public static let `default` = 0.250
}

#endif

extension TimeInterval {

  public static let short = `default` * 0.8 // 0.200s, dismiss
  public static let long = `default` * 1.2 // 0.300s, present
  public static let longer = `default` * 1.5 // 0.375s, dismiss large UI
  public static let longest = `default` * 2.0 // 0.500s, large UI
}
