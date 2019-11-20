import Swift

/// A class of types whose references hold the value of an entity with stable
/// identity.
///
/// This class aims to replace **Swift's** `Identifiable` protocol only
/// available in **Swift 5.1**.
public protocol ReferenceIdentifiable {

  /// A type representing the stable identity of the entity associated with `self`.
  associatedtype ID: Codable = String?

  /// The type of the `Self` object.
  associatedtype ReferenceType: AnyObject

  /// A writable key-path to a reference type holding the identity associated
  /// with `self`.
  typealias IDKeyPath = ReferenceWritableKeyPath<ReferenceType, ID>

  /// A key-path to the stable identity of the entity associated with `self`.
  static var idKeyPath: IDKeyPath { get }
}

/// A class of types whose instances hold the value of an entity with stable
/// identity.
///
/// This class aims to replace **Swift's** `Identifiable` protocol only
/// available in **Swift 5.1**.
public protocol Identifiable {

  /// A type representing the stable identity of the entity associated with `self`.
  associatedtype ID: Codable

  /// A writable key-path to a reference type holding the identity associated
  /// with `self`.
  typealias IDKeyPath = KeyPath<Self, ID>

  /// A key-path to the stable identity of the entity associated with `self`.
  static var idKeyPath: IDKeyPath { get }
}

// MARK: - Default implementations

/// Automatic synthesis for the identification of `Identifiable` types whose
/// `ID` is of a `String` type.
extension Identifiable where ID: StringProtocol {

  public var id: String {
    .init(self[keyPath: Self.idKeyPath])
  }
}

/// Automatic synthesis for the identification of `Identifiable` types whose
/// `ID` is of an `UnsignedInteger` type, eg. `UInt`.
extension Identifiable where ID: BinaryInteger & UnsignedInteger {

  public var id: UInt {
    .init(truncatingIfNeeded: self[keyPath: Self.idKeyPath])
  }
}

/// Automatic synthesis for the identification of `Identifiable` types whose
/// `ID` is of an `SignedInteger` type, eg. `Int`.
extension Identifiable where ID: BinaryInteger & SignedInteger {

  public var id: Int {
    .init(truncatingIfNeeded: self[keyPath: Self.idKeyPath])
  }
}

