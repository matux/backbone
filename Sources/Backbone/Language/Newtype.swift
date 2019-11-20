/// `Newtype` is a cheap trivial implementation of a Singleton-type, or a Tagged-
/// type in FP parlance. More concretely, `Newtype` is like a stolen `Tagged`
/// that was scrapped and sold for parts. A glorified typealias that can be
/// type-checked.
///
/// `Newtype` provides a simple mechanism for typifying values intended to hold
/// specific data and whose types do not reflect such specificity.
///
/// - Remark: As with everything nowadays, this was brought to you by "someone
///   doing Haskell" some 153 years ago.
///
/// The declarative context of a value is meaningless to a type-checker, that
/// is to say, the semantic meaning of a value ultimately begins and ends with
/// its type definition. We usually annotate variables holding data such as
/// emails, identifiers or passwords with general-purpose types such as
/// `String`; by doing this, we are missing important gurantees the compiler
/// can make for us, for example, say we define a `String` password except we
/// specify it with some `Password` type, now, the compiler can stop us from
/// shoving stuff in it that is not a `Password`, like a "naked" string, or an
/// integer, or a shoe.
///
/// `Newtype` supports both nominal and structural types, if you don't know what
/// that means, it doesn't matter, you wouldn't understand.
///
/// `Newtype` achieves its specificity by binding a type to another one, namely
/// the "specifier". The specifier is known as a "Phantom Type".
///
/// Phantom Types draw their powers from the carcasses of deleted code; poor
/// souls long-forgotten by the very programmers who enthusiastically brought
/// them into existence only to be quickly discarded and replaced with a better
/// implementation they saw in stackoverflow. These Phantom Types act as a
/// conduit between our higher plane of statically-typed existence and the world
/// known as... "The Undertype".
///
/// ### Example
///     typealias Email = Newtype<String, ᵀEmail> ; enum ᵀEmail {}
///     typealias ID = Newtype<Int, ᵀId> ; enum ᵀId {}
///     typealias TRex = Newtype<Tyrannosaurus, ᵀRex> ; enum ᵀRex {}
///
///     struct TRexOwner {
///       let uniqueIdentifier: ID
///       let contact: Email
///       let dinosaur = Newtype<Tyrannosaurus, Rex>(dinosaur)
///     }
///
/// ---
///
/// **See also**
///   - [Newtype](new)
///   - [Tagged types](tagged)
///   - [Phantom types](phantom)
///   - [Refined types](refined)
///
/// **Further reading**
/// - [First-Class Phantom Types](https://ecommons.cornell.edu/bitstream/handle/1813/5614/TR2003-1901.pdf?sequence=1&isAllowed=y)
///   : Go straight to the last page and all shall become clear...
///
/// - [new]: https://wiki.haskell.org/Newtype
/// - [tagged]: https://medium.com/iterators/to-tag-a-type-88dc344bb66c
/// - [phantom]: https://wiki.haskell.org/Phantom_type
/// - [refined]: https://ucsd-progsys.github.io/liquidhaskell-tutorial/03-basic.html
public struct Newtype<Derived, Tag>: SelfAware {

  /// The underlying type.
  ///
  /// This `typealias` allows proper access to the underlying type:
  ///
  ///     typealias Vars = Newtype<UserDefaults, Tag> ; enum Tag {}
  ///     Vars.Raw.resetStandardUserDefaults()
  ///     // Calls `UserDefaults.resetStandardUserDefaults`
  ///
  ///     let type = Vars.Raw.self
  ///     print(type)
  ///     // Prints "UserDefaults.Type"
  public typealias Derived = Derived

  /// The value `Newtype` is refining.
  public var rawValue: Derived

  /// Creates a new instance of this `Newtype`.
  public init(_ value: Derived) {
    rawValue = value
  }
}

extension Newtype: RawRepresentable {

  public init(rawValue: Derived) {
    self.rawValue = rawValue
  }
}

extension Newtype: Equatable where Derived: Equatable { }
extension Newtype: Hashable where Derived: Hashable { }
extension Newtype: Comparable where Derived: Comparable { }
extension Newtype: Decodable where Derived: Decodable { }
extension Newtype: Encodable where Derived: Encodable { }
//extension Newtype: CustomStringConvertible where Derived: CustomStringConvertible { }
extension Newtype: CustomDebugStringConvertible where Derived: CustomDebugStringConvertible { }
extension Newtype: CustomReflectable where Derived: CustomReflectable { }
extension Newtype: ExpressibleByStringValue where Derived: ExpressibleByStringValue { }

// MARK: -

/// The type of values that don't bind to variables.
public typealias Unbound = (Nothing) -> Anything

/// The type of parameters that bind to no arguments.
///
/// Denotes a parameter to be delivered in the future in a function that will
/// be partially applied.
///
/// A type that denotes a parameter in a partially applied function whose
/// argument will be provided later.
///
///     public func pair<A, B>(_ x: A, _: (·)) -> (_ y: B) -> (A, B) {
///       return { y in (x, y) }
///     }
public typealias · = Newtype<Unbound, ⁺UVar> ; public enum ⁺UVar {}

/// The type of primary parameters that bind to no arguments.
public typealias Unbound$0 = Newtype<Unbound, ⁺⁰UVar> ; public enum ⁺⁰UVar {}

/// The type of secondary parameters that bind to no arguments.
public typealias Unbound$1 = Newtype<Unbound, ⁺¹UVar> ; public enum ⁺¹UVar {}

/// The type of tertiary parameters that bind to no arguments.
public typealias Unbound$2 = Newtype<Unbound, ⁺²UVar> ; public enum ⁺²UVar {}

/// Explicitly indicates into what parameter within a function should a
/// pointfree argument be mapped.
///
/// Trivial example:
///
///     let oldErrors: [Error] = [1, 2, 3]
///     let newErrors: [Error]? = ["a", "b", "c"]
///     let errors: ([Error], [Error])? = newErrors.map(zip(__, oldErrors))
///     print(allErrors)
///     // prints "(["a", "b", "c"], [1, 2, 3])"
public let __ = (·)(absurd)

/// Explicitly indicates into what parameter in a function should a pointfree
/// argument be mapped.
public let ˙$ = Unbound$0(absurd) // ⌥h

/// Explicitly indicates into what parameter in a function should a pointfree
/// argument be mapped.
public let ˙$0 = Unbound$0(absurd) // ⌥h

/// Explicitly indicates into what parameter in a function should a pointfree
/// argument be mapped.
public let ˙$1 = Unbound$1(absurd)

/// Explicitly indicates into what parameter in a function should a pointfree
/// argument be mapped.
public let ˙$2 = Unbound$1(absurd)
