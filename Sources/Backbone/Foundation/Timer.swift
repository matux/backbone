import Foundation

extension Timer /*: CustomStringConvertible*/ {

  open override var description: String {
    return timeInterval.isZero
      ? "in \(DecimalFormatter.format(fireDate.timeIntervalSinceNow))s"
      : "every \(DecimalFormatter.format(timeInterval))s"
      |> { "Timer ⁞ \($0)(\(tolerance)s) valid: \(isValid)" }
  }
}

extension Timer {

  @inlinable
  public var timeToFire: TimeInterval {
    return fireDate.timeIntervalSinceNow
  }

  /// Returns a `Timer` that repeatedly reschedules itself until invalidated.
  ///
  /// Creates a recurring `Timer` initialized with the specified closure,
  /// scheduling it on the current run loop in the default mode.
  ///
  /// - Attention: Tolerance is automatically set to 10% of the given timing
  ///   as recommended by Apple guidelines.
  ///
  /// - Note: The `Timer` **must** be invalidated from within the given closure.
  /// - Parameters:
  ///   - interval: The number of seconds between firings of the timer. If
  ///     seconds is less than or equal to 0.0, the Timer defaults to 0.1ms.
  ///   - perform: The execution body of the timer; the timer itself is passed
  ///     as the parameter to this block when executed to aid in avoiding
  ///     cyclical references.
  @inlinable
  @available(OSX 10.12, *)
  public class func every(
    _ interval: Measurement<Seconds>,
    do fire: @escaping (Timer) -> ()
  ) {
    Timer.scheduledTimer(
      withTimeInterval: *interval,
      repeats: true,
      block: fire
    ) |> \.tolerance .= *interval * 0.1
  }

  /// Returns a `Timer` that repeatedly reschedules itself until invalidated.
  ///
  /// Creates a recurring `Timer` initialized with the specified closure,
  /// scheduling it on the current run loop in the default mode.
  ///
  /// - Attention: Tolerance is automatically set to 10% of the given timing
  ///   as recommended by Apple guidelines.
  ///
  /// - Note: The `Timer` can be invalidated from within the given closure.
  /// - Parameters:
  ///   - interval: The number of seconds between firings of the timer. If
  ///     seconds is less than or equal to 0.0, the Timer defaults to 0.1ms.
  ///   - skipped:
  ///   - perform: The execution body of the timer; the timer itself is passed
  ///     as the parameter to this block when executed to aid in avoiding
  ///     cyclical references
  /// - Returns: The `Timer` created. Discardable if invalidating from within
  ///   the closure passed.
  @inlinable
  @available(OSX 10.12, *)
  public class func every(
    _ interval: Measurement<Seconds>,
    until shouldInvalidate: @escaping @autoclosure () -> Bool,
    when shouldFire: @escaping @autoclosure () -> Bool = true,
    do fire: @escaping () -> ()
  ) {
    Timer.scheduledTimer(
      withTimeInterval: *interval,
      repeats: true,
      block: iff(const(shouldInvalidate()), invalidate, else: when(shouldFire, fire) • void)
    ).tolerance = *interval * 0.1
  }

  /// Returns a _non-repeating_ _scheduled_ `Timer` that will invoke a closure
  /// in the amount of seconds specified.
  ///
  /// The `Timer` is automatically invalidated when the countdown is over.
  ///
  /// Tolerance is automatically set to **10%** of the given delay as
  /// recommended by Apple guidelines.
  ///
  /// - Note: For a void-returning non-repeating countdown, see [Dispatch.in][1].
  ///
  /// - Parameters:
  ///   - delay: Seconds until the timer fires.
  ///   - perform: The closure to call on firing.
  /// - Returns: The scheduled `Timer`.
  ///
  /// [1]: x-source-tag://Dispatch.in
  @inlinable
  @discardableResult
  @available(OSX 10.12, *)
  public class func `in`(
    _ delay: Measurement<Seconds>,
    do fire: @escaping () -> ()
  ) -> Timer {
    .scheduledTimer(
      withTimeInterval: *delay,
      repeats: false,
      block: discard >>> fire
    ) |> \.tolerance ~ *delay * 0.1
  }

  /// Returns a **non-repeating** scheduled `Timer` that will invoke a closure
  /// in the amount of seconds specified.
  ///
  /// Schedules a delayed `Timer`, by providing the `shouldFire` parameter,
  /// firing is predicated on whether `shouldFire` evaluates to `true`.
  ///
  ///     Timer.if(
  ///       in: 5.secs,
  ///       weak { $0.daon.lastEvent ∈ [.none, .reset] },
  ///       do: weak { $0.customIssue = .faceNotVisible })
  ///
  /// In the example above, a newly run-loop-scheduled `Timer` will set the
  /// custom issue to `.faceNotVisible` in 5 seconds, provided the last event
  /// is either `.none` or `.reset`.
  ///
  /// The `Timer` is automatically invalidated when the countdown is over,
  /// whether the firing occurred or not.
  ///
  /// Tolerance is automatically set to **10%** of the given delay as
  /// recommended by Apple guidelines.
  ///
  /// - Parameters:
  ///   - delay: Seconds until the timer fires.
  ///   - shouldFire: A condition determining whether the timer should fire
  ///     checked at the moment of firing. The condition is wrapped in an
  ///     `Optional` to support `weak` references to `self`. Defaults to `true`.
  ///   - perform: The closure to call on firing.
  /// - Returns: Returns a **non-repeating** scheduled `Timer`.
  @inlinable
  @discardableResult
  @available(OSX 10.12, *)
  public class func `if`(
    in delay: Measurement<Seconds>,
    _ shouldFire: @escaping @autoclosure () -> Bool = true,
    do fire: @escaping () -> ()
  ) -> Timer  {
    .scheduledTimer(
      withTimeInterval: *delay,
      repeats: false,
      block: { _ in when(shouldFire(), fire) }
    ) |> \.tolerance ~ *delay * 0.1
  }

  /// Stops the timer from ever firing again and requests its removal from its
  /// run loop.
  ///
  /// This method is the only way to remove a timer from an `RunLoop` object.
  /// The `RunLoop` object removes its strong reference to the timer, either
  /// just before the `invalidate()` method returns or at some later point.
  ///
  /// If it was configured with target and user info objects, the receiver
  /// removes its strong references to those objects as well.
  @inlinable
  public class func invalidate(_ timer: Timer) {
    timer.invalidate()
  }
}

extension NSObject {

  /// Returns a _non-repeating_ _scheduled_ `Timer` that will invoke a closure
  /// in the amount of seconds specified.
  ///
  /// The `Timer` is automatically invalidated when the countdown is over.
  ///
  /// Tolerance is automatically set to **10%** of the given delay as
  /// recommended by Apple guidelines.
  ///
  /// - Note: For a void-returning non-repeating countdown, see [Dispatch.in][1].
  ///
  /// - Parameters:
  ///   - delay: Seconds until the timer fires.
  ///   - perform: The closure to call on firing.
  /// - Returns: The scheduled `Timer`.
  ///
  /// [1]: x-source-tag://Dispatch.in
  @inlinable
  @available(OSX 10.12, *)
  public func `in`(_ delay: Measurement<Seconds>, do fire: @escaping () -> ()) {
    Timer.in(delay, do: weak { _ in fire() }).tolerance = *delay * 0.1
  }

  /// Schedules a `Timer` bound to a `weak self` that repeatedly reschedules
  /// itself until either it is invalidated.
  ///
  /// Creates a recurring `Timer` initialized with the specified closure,
  /// scheduling it on the current run loop in the default mode.
  ///
  /// - Attention: Tolerance is automatically set to 10% of the given timing
  ///   as recommended by Apple guidelines.
  ///
  /// - Note: The `Timer` can be invalidated from within the given closure.
  /// - Parameters:
  ///   - interval: The number of seconds between firings of the timer. If
  ///     seconds is less than or equal to 0.0, the Timer defaults to 0.1ms.
  ///   - skipped:
  ///   - perform: The execution body of the timer; the timer itself is passed
  ///     as the parameter to this block when executed to aid in avoiding
  ///     cyclical references
  /// - Returns: The `Timer` created. Discardable if invalidating from within
  ///   the closure passed.
  @inlinable
  @available(OSX 10.12, *)
  public func every(
    _ interval: Measurement<Seconds>,
    until shouldInvalidate: @escaping @autoclosure () -> Bool = true,
    when shouldFire: @escaping @autoclosure () -> Bool = true,
    do fire: @escaping () -> ()
  ) {
    Timer.every(
      interval,
      until: { [weak self] in shouldInvalidate() || self.isNil }(),
      when: shouldFire(),
      do: fire)
  }
}
