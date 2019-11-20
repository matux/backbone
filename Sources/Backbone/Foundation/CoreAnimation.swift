import QuartzCore

extension CAMediaTimingFunction: SelfAware {

  /// Linear pacing, which causes an animation to occur evenly over its
  /// duration.
  ///
  /// This is a Bézier timing function with control points (`0.0`, `0.0`) and
  /// (bn;`1.0`, `1.0`.
  public static let linear = Self(name: .linear)

  /// Ease-in pacing, which causes an animation to begin slowly and then speed
  /// up as it progresses.
  ///
  /// This is a Bézier timing function with the control points (`0.42`, `0.0`)
  /// and (`1.0`, `1.0`).
  public static let easeIn = Self(name: .easeIn)

  /// Ease-out pacing, which causes an animation to begin quickly and then slow
  /// as it progresses.
  public static let easeOut = Self(name: .easeOut)

  /// Ease-in-ease-out pacing, which causes an animation to begin slowly,
  /// accelerate through the middle of its duration, and then slow again before
  /// completing.
  public static let easeInOut = Self(name: .easeInEaseOut)

  /// The system default timing function. Use this function to ensure that the
  /// timing of your animations matches that of most system animations.
  public static let `default` = Self(name: .default)
}
