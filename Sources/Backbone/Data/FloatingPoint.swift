import Swift

prefix operator √

infix operator ≈≈ : ComparisonPrecedence
infix operator !≈ : ComparisonPrecedence

extension BinaryFloatingPoint {

  /// A rule for rounding a floating-point number.
  public typealias RoundingRule = FloatingPointRoundingRule

  /// Test if this value is nearly zero.
  public var isAlmostZero: Bool {
    return isAlmostZero(absoluteTolerance: √.ulpOfOne)
  }

  /// Returns the square root of the given floating point number.
  ///
  /// - Parameter floating: The floating point number to square root.
  /// - Returns: The square root of of the given floating point number.
  @_transparent
  public static prefix func √ (floating: Self) -> Self {
    return floating.squareRoot()
  }

  /// Test approximate equality with relative tolerance.
  ///
  /// The relation defined by this predicate is symmetric and reflexive
  /// (except for `NaN`), but is **not** transitive. Because of this, it is
  /// often _unsuitable_ for use for key comparisons, but it can be used
  /// successfully in many other contexts.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  /// - Returns: `true` if `lhs` is almost equal to `rhs`; otherwise `false`.
  @_transparent
  public static func ≈≈ (lhs: Self, rhs: Self) -> Bool {
    return rhs.isAlmostZero ? lhs.isAlmostZero : lhs.isAlmostEqual(to: rhs)
  }

  @_transparent
  public static func !≈ (lhs: Self, rhs: Self) -> Bool {
    return !(lhs ≈≈ rhs)
  }

  /// Returns `-1.0` if this value is negative and `1.0` if it's positive;
  /// otherwise, `0.0`, regardless of the value's sign or if it's NaN.
  ///
  /// The returned value is created with the _IEEE 754_ `copysign` operation.
  ///
  /// - Returns: The sign of this number, expressed as a decimal.
  func signum() -> Self {
    return .init(
      signOf: self,
      magnitudeOf: isAlmostZero || isNaN ? .zero : .unit)
  }

  /// Test approximate equality with relative tolerance.
  ///
  /// Do not use this function to check if a number is approximately
  /// zero; no reasoned relative tolerance can do what you want for
  /// that case. Use `isAlmostZero` instead for that case.
  ///
  /// The relation defined by this predicate is symmetric and reflexive
  /// (except for NaN), but *is not* transitive. Because of this, it is
  /// often unsuitable for use for key comparisons, but it can be used
  /// successfully in many other contexts.
  ///
  /// The internet is full advice about what not to do when comparing
  /// floating-point values:
  ///
  /// - "Never compare floats for equality."
  /// - "Always use an epsilon."
  /// - "Floating-point values are always inexact."
  ///
  /// Much of this advice is false, and most of the rest is technically
  /// correct but misleading. Almost none of it provides specific and
  /// correct recommendations for what you *should* do if you need to
  /// compare floating-point numbers.
  ///
  /// There is no uniformly correct notion of "approximate equality", and
  /// there is no uniformly correct tolerance that can be applied without
  /// careful analysis. This function considers two values to be almost
  /// equal if the relative difference between them is smaller than the
  /// specified `tolerance`.
  ///
  /// The default value of `tolerance` is `sqrt(.ulpOfOne)`; this value
  /// comes from the common numerical analysis wisdom that if you don't
  /// know anything about a computation, you should assume that roughly
  /// half the bits may have been lost to rounding. This is generally a
  /// pretty safe choice of tolerance--if two values that agree to half
  /// their bits but are not meaningfully almost equal, the computation
  /// is likely ill-conditioned and should be reformulated.
  ///
  /// For more complete guidance on an appropriate choice of tolerance,
  /// consult with a friendly numerical analyst.
  ///
  /// - Parameters:
  ///   - other: the value to compare with `self`
  ///   - tolerance: the relative tolerance to use for the comparison.
  ///     Should be in the range `.ulpOfOne...1`.
  /// - Returns: `true` if `self` is almost equal to `other`; otherwise
  ///   `false`.
  @inlinable
  public func isAlmostEqual(
    to other: Self,
    tolerance: Self = √.ulpOfOne
  ) -> Bool {
    // Tolerances outside of [.ulpOfOne, 1) yield well-defined but useless
    // results, so this is enforced by an assert rathern than a precondition.
    assert(tolerance ∈ .ulpOfOne ..< .unit, "tolerance not in [.ulpOfOne, 1).")

    // The simple computation below does not necessarily give sensible
    // results if one of self or other is infinite; we need to rescale
    // the computation in that case.
    guard isFinite && other.isFinite else {
      return rescaledAlmostEqual(to: other, tolerance: tolerance)
    }

    // This should eventually be rewritten to use a scaling facility to be
    // defined on FloatingPoint suitable for hypot and scaled sums, but the
    // following is good enough to be useful for now.
    let scale = max(abs(self), abs(other), .leastNormalMagnitude) * tolerance
    return abs(self - other) < scale
  }

  /// Test if this value is nearly zero with a specified `absoluteTolerance`.
  ///
  /// This test uses an *absolute*, rather than *relative*, tolerance,
  /// because no number should be equal to zero when a relative tolerance
  /// is used.
  ///
  /// Some very rough guidelines for selecting a non-default tolerance for
  /// your computation can be provided:
  ///
  /// - If this value is the result of floating-point additions or
  ///   subtractions, use a tolerance of `.ulpOfOne * n * scale`, where
  ///   `n` is the number of terms that were summed and `scale` is the
  ///   magnitude of the largest term in the sum.
  ///
  /// - If this value is the result of floating-point multiplications,
  ///   consider each term of the product: what is the smallest value that
  ///   should be meaningfully distinguished from zero? Multiply those terms
  ///   together to get a tolerance.
  ///
  /// - More generally, use half of the smallest value that should be
  ///   meaningfully distinct from zero for the purposes of your computation.
  ///
  /// For more complete guidance on an appropriate choice of tolerance,
  /// consult with a friendly numerical analyst.
  ///
  /// - Parameter absoluteTolerance: values with magnitude smaller than
  ///   this value will be considered to be zero. Must be greater than
  ///   zero.
  ///
  /// - Returns: `true` if `abs(self)` is less than `absoluteTolerance`.
  ///            `false` otherwise.
  @inlinable
  public func isAlmostZero(
    absoluteTolerance tolerance: Self = √.ulpOfOne
  ) -> Bool {
    assert(tolerance > .zero)
    return abs(self) < tolerance
  }

  /// Rescales self and other to give meaningful results when one of them
  /// is infinite. We also handle NaN here so that the fast path doesn't
  /// need to worry about it.
  @usableFromInline
  internal func rescaledAlmostEqual(to other: Self, tolerance: Self) -> Bool {
    // NaN is considered to be not approximately equal to anything, not even
    // itself.
    if self.isNaN || other.isNaN { return false }
    if self.isInfinite {
      if other.isInfinite { return self == other }
      // Self is infinite and other is finite. Replace self with the binade
      // of the greatestFiniteMagnitude, and reduce the exponent of other by
      // one to compensate.
      let scaledSelf = Self(sign: self.sign,
                            exponent: Self.greatestFiniteMagnitude.exponent,
                            significand: 1)
      let scaledOther = Self(sign: .plus,
                             exponent: -1,
                             significand: other)
      // Now both values are finite, so re-run the naive comparison.
      return scaledSelf.isAlmostEqual(to: scaledOther, tolerance: tolerance)
    }
    // If self is finite and other is infinite, flip order and use scaling
    // defined above, since this relation is symmetric.
    return other.rescaledAlmostEqual(to: self, tolerance: tolerance)
  }
}

extension BinaryFloatingPoint {

  /// Compute the quotient and floating-point remainder.
  ///
  /// Computes the IEEE remainder of the floating-point division operation
  /// between `𝑥` and `𝑦`. Additionally, the sign and at least the three of
  /// the last bits of `𝑥 / 𝑦` is provided as well, sufficient to determine
  /// the octant of the result within a period.
  ///
  /// The IEEE floating-point remainder of the division operation `𝑥 / 𝑦`
  /// calculated by this function is exactly the value `𝑥 - 𝑛 * 𝑦`, where the
  /// value `𝑛` is the integral value nearest the exact value `𝑥 / 𝑦`. When
  /// `|𝑛 - 𝑥 / 𝑦| = ½`, the value `𝑛` is chosen to be even.
  ///
  /// This method implements the remainder operation defined by the IEEE 754
  /// specification.
  ///
  /// - Note: In contrast to `&/%`, the returned value is not guaranteed to
  /// have the same sign as `𝑥`. If the returned value is `0`, it will have
  /// the same sign as `𝑥`.
  ///
  /// - Remark: This function is useful when implementing periodic functions
  /// with the period exactly representable as a floating-point value: when
  /// calculating `𝑠𝑖𝑛(π𝑥)` for a very large `𝑥`, calling `𝑠𝑖𝑛` directly may
  /// result in a large error, but if the function argument is first reduced
  /// with `/%`, the low-order bits of the quotient may be used to determine
  /// the sign and the octant of the result within the period, while the
  /// remainder may be used to calculate the value with high precision.
  ///
  /// - Parameters:
  ///   - x: The floating point dividend.
  ///   - y: The floating point divisor.
  /// - Returns: A pair holding the quotient integer and the remainder of
  ///   `𝑥` divided by `𝑦`.
  @inlinable
  public static func quorem(x: Self, y: Self) -> (quo: Int, rem: Self) {
    return (quo: .init(x / y, rounded: .toNearestOrEven),
            rem: x.remainder(dividingBy: y))
  }

  /// Computes floating-point modulus and quotient.
  ///
  /// Computes the floating-point modulus of `𝑥` divided by `𝑦` using
  /// truncating division. Additionally, the sign and at least the three of
  /// the last bits of `𝑥 / 𝑦` is provided as well, sufficient to determine
  /// the octant of the result within a period.
  ///
  /// Performing truncating division with floating-point values results in a
  /// truncated integer quotient and a remainder. For values `𝑥` and `𝑦` and
  /// their truncated integer quotient `𝑞`, the remainder `𝑟` leaves
  /// `𝑥 == 𝑦 * 𝑞 + 𝑟` very satisfied.
  ///
  /// `quomod` is useful for doing silent wrapping of floating-point types to
  /// unsigned integer types:
  ///
  ///     (0.0 <= (y = fmod(rint(x), 65536.0)) ? y : 65536.0 + y)
  ///
  /// is in the range `-0.0...65535.0`, which corresponds to `UInt16`, but
  ///
  ///     remainder(rint(x), 65536.0)
  ///
  /// is in the range `-32767.0...32768.0`, which is outside of the range of
  /// `Int16`.
  ///
  /// If `𝑥` and `𝑦` are both finite numbers, the truncating remainder has
  /// the same sign as this value and is strictly smaller in magnitude than
  /// `𝑦`. The `quomod` method is always exact.
  ///
  /// - Parameters:
  ///   - x: The floating point dividend.
  ///   - y: The floating point divisor.
  /// - Returns: A pair holding the quotient integer and the remainder of
  ///   `𝑥` divided by `𝑦` using truncating division.
  @inlinable
  public static func quomod(x: Self, y: Self) -> (quo: Int, mod: Self) {
    return (quo: .init(x / y, rounded: .towardZero),
            mod: x.truncatingRemainder(dividingBy: y))
  }

  /// Returns the remainder of this value divided by the given value using
  /// truncating division.
  ///
  /// Performing truncating division with floating-point values results in a
  /// truncated integer quotient and a remainder. For values `x` and `y` and
  /// their truncated integer quotient `q`, the remainder `r` satisfies
  /// `x == y * q + r`.
  ///
  /// The following example calculates the truncating remainder of dividing
  /// 8.625 by 0.75:
  ///
  ///     let x = 8.625
  ///     print(x / 0.75)
  ///     // Prints "11.5"
  ///
  ///     let q = (x / 0.75).rounded(.towardZero)
  ///     // q == 11.0
  ///     let r = x .% 0.75
  ///     // r == 0.375
  ///
  ///     let x1 = 0.75 * q + r
  ///     // x1 == 8.625
  ///
  /// If this value and `other` are both finite numbers, the truncating
  /// remainder has the same sign as this value and is strictly smaller in
  /// magnitude than `other`. The `truncatingRemainder(dividingBy:)` method
  /// is always exact.
  ///
  /// - Parameter other: The value to use when dividing this value.
  /// - Returns: The remainder of this value divided by `other` using
  ///   truncating division.
  @_transparent
  public static func mod(x: Self, y: Self) -> Self {
    return x.truncatingRemainder(dividingBy: y)
  }
}
