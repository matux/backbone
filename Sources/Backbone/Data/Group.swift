import Swift

///┌──────────────╥─────┬─────┬─────┬─────┬─────╥─────┐
///│ ░▒▓██████▓▒░ ║AA->A│⁽⁾⁼⁽⁾│  ε  │ 𝑥⁻¹ │ˣʸ⁼ʸˣ║  ·  │
///├══════════════╬─────┼─────┼─────┼─────┼─────╬─────┤
// │ Semigroupoid ║░░░░░│  ✓  │░░░░░│░░░░░│░░░░░║  ◦  │
// │     Category ║░░░░░│  ✓  │  ✓  │░░░░░│░░░░░║  ε  │
// │     Groupoid ║░░░░░│  ✓  │  ✓  │  ✓  │░░░░░║ 𝑥⁻¹ │
///│        Magma ║  ✓  │░░░░░│░░░░░│░░░░░│░░░░░║  ·  │
// │   Quasigroup ║  ✓  │░░░░░│░░░░░│  ✓  │░░░░░║  -  │
///│    Semigroup ║  ✓  │  ✓  │░░░░░│░░░░░│░░░░░║  +  │
// │         Loop ║  ✓  │░░░░░│  ✓  │  ✓  │░░░░░║  ÷  │
///│       Monoid ║  ✓  │  ✓  │  ✓  │░░░░░│░░░░░║ + × │
///│        Group ║  ✓  │  ✓  │  ✓  │  ✓  │░░░░░║ 𝑥⁻¹ │
// │Abelian Group ║  ✓  │  ✓  │  ✓  │  ✓  │  ✓  ║ ⊕ ⊗ │
///└──────────────╨─────┴─────┴─────┴─────┴─────╨─────┘
//

/// A `Monoid` satisfying invertibility; or equivalently, an element that
/// can _undo_ the effect of the `Semigroup` operation.
///
/// An element `𝑎` in a `Monoid` `(𝐴,͏⧺,𝑒)`is said to have an inverse,
/// denoted by `𝑎⁻¹`, iff `𝑎 ⧺ 𝑎⁻¹ = 𝑎⁻¹ ⧺ 𝑎 = 𝑒`. That is, if we multiply
/// the element with it’s inverse in any order we get back to the identity
/// element.
public protocol Group: Monoid {

  /// Returns the inverse of this instance.
  var inverse: Self { get }
}

extension Group {

  /// The inverse of this instance.
  public var ⁻¹: Self {
    return inverse
  }

  /// Inverts this instance.
  public mutating func invert() {
    self = inverse
  }

  /// Remove a value from this instance.
  public mutating func remove(_ x: Self) {
    self = self.removing(x)
  }

  /// Returns a new instance with the given value removed from it.
  public func removing(_ x: Self) -> Self {
    return self ++ x.⁻¹
  }

  /// Returns an indication of the extent to which a certain binary
  /// operation fails to be commutative.
  public static func commutator(_ x: Self, _ y: Self) -> Self {
    return x ++ y ++ x.⁻¹ ++ y.⁻¹
  }
}

// MARK: - Definitions

extension Group where Self: SignedNumeric {

  public var inverse: Self {
    return negated()
  }

  public mutating func invert() {
    negate()
  }

}

//extension Int: Group {}
//extension Int8: Group { }
//extension Int16: Group { }
//extension Int32: Group { }
//extension Int64: Group { }
//extension Float: Group { }
//extension Double: Group { }
//extension CGFloat: Group { }
//extension Decimal: Group { }
//
//#if os(OSX)
//extension Float80: Group { }
//#endif

//extension Bool: Group {
//
//    public func inverse() -> Bool {
//        return !self
//    }
//}

//extension Int: Group {
//
//    public func inverse() -> Int {
//        return -self
//    }
//}
