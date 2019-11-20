import Foundation

/// Namespace for type-related support.
public enum Type {

  /// Namespace for unsafe type-related operations.
  public enum Unsafe { }
}

public enum T<Γ> {
  public enum Error<T>: Swift.Error {
    case cast(T: T.Type, Γ: Γ.Type)
  }

  public static var `in`: (Γ) -> Γ { id }
  public static var `is`: (Any) -> Bool { { $0 is Γ } }
  public static var cast: (Any) -> Γ? { { $0 as? Γ } }
  public static var castǃ: (Any) -> Γ { { $0 as! Γ } }
  public static func reinterpretCast<T>(_ x: T) -> Γ {
    unsafeBitCast(x, to: Γ.self)
  }

  public static prefix func ∈ <τ>(type: T<Γ>.Type) -> (τ) -> Bool {
    type.is
  }

  public static func ∈ <τ>(value: τ, type: T<Γ>.Type) -> Bool {
    type.is(value)
  }
}

/// A hole in our code.
///
/// - Returns: The type they were looking for.
@_transparent
public func hole<T>() -> T {
  raise(.undef("""
    We went looking for a \(T.self)
    but all we found was a hole.
  """))
}

extension Type {

  /// Forces the type checker to infer the type of a generic instance.
  ///
  /// Use `Type.infer` within a generic expression to compel the type checker
  /// to resolve `T` by taking into account elements from the context that
  /// may otherwise ignore.
  ///
  /// - Parameter a: The instance to infer.
  /// - Returns: The instance inferred or fails to compile.
  @_transparent
  public static func infer<Γ>(_ x: Γ) -> Γ {
    T.in(x)
  }

  /// Provides a generic expression with context.
  ///
  /// The identity function returned will compile if and only if it is given
  /// instances of the annotated type.
  @_transparent
  public static func `in`<τ>(_: τ.Type) -> (τ) -> τ {
    T.in
  }
 
  /// Returns a function that will indicate whether any value it is given is
  /// of type `A`.
  ///
  /// A functional, higher-order variant of the type checking infix `is`.
  @_transparent
  public static func `is`<τ, tʹ>(_: τ.Type) -> (tʹ) -> Bool {
    T<τ>.is
  }

  /// Returns an `Optional` with the result of downcasting `a` as `B` or
  /// `.none` if the operation attempt is unsuccessful.
  ///
  /// A functional synonym of the conditional type downcast infix `as?`.
  ///
  ///     1> let keyValues = [String: Any]()
  ///     2> let value = keyValues["someKey"] => T.as(Int.self)
  ///     // value: Int? = nil
  @_transparent
  public static func `as`<Γ, τ>(_: Γ.Type) -> (τ) -> Γ? {
    T.cast
  }

  /// Attempts to force-unwrap the result of casting the given instance to the
  /// given type or **crashes gruesomely.**
  ///
  /// A functional synonym of the force type-downcast infix `as!`.
  ///
  /// - Requires: `x` is a `Γ`.
  @_transparent
  public static func asǃ<Γ, τ>(_: Γ.Type) -> (τ) -> Γ {
    T.castǃ
  }

  /// Returns an `Optional` with the result of downcasting `a` as `B` or
  /// `.none` if the operation attempt is unsuccessful.
  ///
  /// A functional synonym of the conditional type downcast infix `as?`.
  @_transparent
  public static func cast<Γ>(_ x: Any?) -> Γ? {
    T<Γ>.cast(x)
  }

  /// Attempts to force-unwrap the result of casting the given instance by
  /// inferring the current context or **crashes spectacularly.**
  ///
  /// A functional synonym of the force type-downcast infix `as!`.
  ///
  /// - Requires: For `a` to be a real `B`.
  @_transparent
  public static func castǃ<Γ>(_ x: Any) -> Γ {
    T.castǃ(x)
  }
}

// MARK: - Force

extension Type.Unsafe {

  /// Returns an `Optional` with the result of downcasting `a` as `B` or
  /// `.none` if the operation attempt is unsuccessful.
  ///
  /// A functional synonym of the conditional type downcast infix `as?`.
  @_transparent
  public static func bridge<Γ: NSObject>(_ x: AnyObject) -> Γ {
    x as! Γ
  }

  /// Returns the given base instance cast unconditionally to a derived class
  /// inferred through context or **crashes disturbingly.**
  ///
  /// Use this function instead of `reinterpretǃ(_:)` since its more
  /// restrictive while still performing debug checks.
  ///
  /// - Important: Types are not tested on -O builds.
  ///
  /// - Warning: Trades safety for performance. Use only if confident that
  ///   `x is T` is `true`, and only if `x as! T` is a performance issue.
  ///
  /// - Requires: The instance passed as `x` must be an instance of type `T`.
  @_transparent
  public static func refine<Γ: AnyObject>(_ x: AnyObject) -> Γ {
    unsafeDowncast(x, to: Γ.self)
  }

  /// Attempts to expose the concrete type of the given value; or **crashes**.
  ///
  /// This cast may allow type punning which might be useful for dispatching
  /// to specializations of generic functions.
  ///
  /// - Requires: `x` must be an instance of type context `Γ`.
  @_transparent
  public static func expose<τ, Γ>(_ x: τ) -> Γ {
    _identityCast(x, to: Γ.self)
  }

  /// Returns the bits of the given instance, reinterpreted as having the
  /// specified type.
  ///
  /// Use this function only to convert the instance passed as `x` to a
  /// layout-compatible type when conversion through other means is not
  /// possible.
  ///
  /// - Requires: The inferred context and the type of `x` must have the same
  ///   size of memory representation and compatible memory layout.
  /// - Parameter x: The instance to cast.
  /// - Returns: A new instance of the type context `Γ`, cast from `x`.
  @_transparent
  public static func reinterpret<τ, Γ>(_ x: τ) -> Γ {
    unsafeBitCast(x, to: Γ.self)
  }
}

// MARK: - Bridge

public let Bridge = Bridging()

@dynamicCallable
public struct Bridging {

  public func dynamicallyCall(withArguments xs: [String]) -> NSString { xs.first! as NSString }
  public func dynamicallyCall<E>(withArguments xs: [E]) -> NSArray { xs as NSArray }
  public func dynamicallyCall<E>(withArguments xs: Set<E>) -> NSSet { xs as NSSet }
  public func dynamicallyCall<K, V>(withArguments xs: [K: V]) -> NSDictionary { xs as NSDictionary }
  public func dynamicallyCall(withArguments xs: NSString) -> String { xs as String }
  public func dynamicallyCall(withArguments xs: NSArray) -> [AnyObject] { xs as Array }
  public func dynamicallyCall(withArguments xs: NSSet) -> Set<AnyHashable> { xs as Set }
  public func dynamicallyCall(withArguments xs: NSDictionary) -> [AnyHashable: Any] { xs as Dictionary }
}

extension Type {

  /// Bridge a String to an NSString.
  @_transparent
  public static func bridge(_ value: String) -> NSString { value as NSString }

  /// Bridge an Array to an NSArray.
  @_transparent
  public static func bridge<Element>(_ value: [Element]) -> NSArray { value as NSArray }

  /// Bridge a Dictionary to an NSDictionary.
  @_transparent
  public static func bridge<K, V>(_ value: [K: V]) -> NSDictionary { value as NSDictionary }

  /// Bridge a Set to an NSSet
  @_transparent
  public static func bridge<E>(_ value: Set<E>) -> NSSet { value as NSSet }

  /// Bridge a NSString to a String.
  @_transparent
  public static func bridge(_ value: NSString) -> String { value as String }

  /// Bridge an NSArray to an Array.
  @_transparent
  public static func bridge(_ value: NSArray) -> [AnyObject] { value as Array }

  /// Bridge a NSSet to an Set
  @_transparent
  public static func bridge(_ value: NSSet) -> Set<AnyHashable> { value as Set }

  /// Bridge an NSDictionary to a Dictionary.
  @_transparent
  public static func bridge(_ value: NSDictionary) -> [AnyHashable: Any] { value as Dictionary }
}

extension Type.Unsafe {

  /// Bridge a `ReferenceConvertible‵ value type to its _Foundation_ counterpart.
  ///
  /// This function can bridge value types conforming to `ReferenceConvertible`,
  /// only.
  ///
  /// ### This is a list of convertible types:
  ///
  ///  * `AffineTransform`
  ///  * `Calendar`
  ///  * `CharacterSet`
  ///  * `Data`
  ///  * `Date`
  ///  * `DateComponents`
  ///  * `DateInterval`
  ///  * `IndexPath`
  ///  * `IndexSet`
  ///  * `INShortcut`
  ///  * `Locale`
  ///  * `Measurement`
  ///  * `Notification`
  ///  * `PersonNameComponents`
  ///  * `TimeZone`
  ///  * `URL`
  ///  * `URLComponents`
  ///  * `URLQueryItem`
  ///  * `URLRequest`
  ///  * `UUID`
  ///
  /// - Parameter value: A value type conforming to `ReferenceConvertible`.
  /// - Returns: The Foundation reference counterpart.
  @_transparent
  public static func bridge<ValueType: ReferenceConvertible>(
    _ value: ValueType
  ) -> ValueType.ReferenceType {
    value as! ValueType.ReferenceType
  }

  /// Bridge a _Foundation_ reference type to its Swift sidekick.
  ///
  /// This function can bridge Foundation object types with an existing
  /// Swift counterpart that conforms to `ReferenceConvertible`.
  ///
  /// ### Convertibles
  ///
  ///  * `NSAffineTransform`
  ///  * `NSCalendar`
  ///  * `NSCharacterSet`
  ///  * `NSData`
  ///  * `NSDate`
  ///  * `NSDateComponents`
  ///  * `NSDateInterval`
  ///  * `NSIndexPath`
  ///  * `NSIndexSet`
  ///  * `NSINShortcut`
  ///  * `NSLocale`
  ///  * `NSMeasurement`
  ///  * `NSNotification`
  ///  * `NSPersonNameComponents`
  ///  * `NSTimeZone`
  ///  * `NSURL`
  ///  * `NSURLComponents`
  ///  * `NSURLQueryItem`
  ///  * `NSURLRequest`
  ///  * `NSUUID`
  ///
  /// - Parameter value: An object with a `ReferenceConvertible` counterpart.
  /// - Returns: The value type.
  @_transparent
  public static func bridge<ValueType: ReferenceConvertible>(
    _ value: ValueType.ReferenceType
  ) -> ValueType {
    value as! ValueType
  }
}

// MARK: - Very experimental

/// Expression type annotation operator.
prefix operator ∶

/// **Experimental** Provides a generic expression with context.
///
/// Use (`∶`) to hone the specification of an expression to find where type
/// errors may be, for the very, _very_ rare cases where Swift gives you a
/// cryptic error message.
///
/// By inserting `:Type.self` anywhere in an expression, you tell the compiler
/// "by the way Mr. Compiler, the type context of the expression _should be_
/// of `Type.self`, so tell me if it's not, aight?"
/// The compiler will then throw an error if it can be proved this may not be
/// the case.
@_transparent
public prefix func ∶ <τ>(rhs: τ.Type) -> (τ) -> τ {
  id
}
