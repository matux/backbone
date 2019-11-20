#if os(iOS)
import UIKit
#endif
import CoreGraphics

extension CGFloat {

  public static let zero = CGFloat()

  @inlinable
  public var rads: CGFloat {
    return .pi * (self / 180.0)
  }

  @inlinable
  public var degs: CGFloat {
    return self * 180.0 / .pi
  }
}

extension CGPoint: ExpressibleByFloatLiteral {

  public static let zero = CGPoint()

  @_transparent
  public init(_ x: CGFloat, _ y: CGFloat) {
    self.init(x: x, y: y)
  }

  @_transparent
  public init(_ x: CGFloat.NativeType, _ y: CGFloat.NativeType) {
    self.init(x: CGFloat(x), y: CGFloat(y))
  }

  @_transparent
  public init(_ size: CGSize) {
    self.init(x: size.width, y: size.height)
  }

  @_transparent
  public init(scalar: CGFloat) {
    self.init(x: scalar, y: scalar)
  }

  @_transparent
  public init(scalar: CGFloat.NativeType) {
    self.init(x: CGFloat(scalar), y: CGFloat(scalar))
  }

  @_transparent
  public init(floatLiteral value: CGFloat.NativeType) {
    self.init(scalar: value)
  }

  @inlinable
  public func swapped() -> CGPoint {
    return .init(x, y)
  }

  @inlinable
  public mutating func swap() -> () {
    (x, y) = (y, x)
  }
}

#if os(iOS)
extension UIOffset {

  public static let zero = UIOffset()

  @_transparent
  public init(_ x: CGFloat, _ y: CGFloat) {
    self.init(horizontal: x, vertical: y)
  }

  @_transparent
  public init(_ x: CGFloat.NativeType, _ y: CGFloat.NativeType) {
    self.init(horizontal: CGFloat(x), vertical: CGFloat(y))
  }

  @_transparent
  public init(scalar: CGFloat) {
    self.init(horizontal: scalar, vertical: scalar)
  }

  @_transparent
  public init(scalar: CGFloat.NativeType) {
    self.init(horizontal: CGFloat(scalar), vertical: CGFloat(scalar))
  }

  @inlinable
  public func swapped() -> UIOffset {
    return .init(horizontal, vertical)
  }

  @inlinable
  public mutating func swap() -> () {
    (horizontal, vertical) = (horizontal, vertical)
  }
}
#endif

extension CGVector {

  public static let zero = CGVector()

  public init(_ dx: CGFloat, _ dy: CGFloat) {
    self.init(dx: dx, dy: dy)
  }

  public init(_ dx: CGFloat.NativeType, _ dy: CGFloat.NativeType) {
    self.init(dx: CGFloat(dx), dy: CGFloat(dy))
  }

  public init(scalar: CGFloat) {
    self.init(dx: scalar, dy: scalar)
  }

  @_transparent
  public init(scalar: CGFloat.NativeType) {
    self.init(dx: CGFloat(scalar), dy: CGFloat(scalar))
  }

  public func swapped() -> CGSize {
    return .init(dx, dy)
  }

  public mutating func swap() -> () {
    (dx, dy) = (dy, dx)
  }
}

extension CGSize: ExpressibleByFloatLiteral {

  public static let zero = CGSize()

  @_transparent
  public init(_ w: CGFloat, _ h: CGFloat) {
    self.init(width: w, height: h)
  }

  @_transparent
  public init(_ w: CGFloat.NativeType, _ h: CGFloat.NativeType) {
    self.init(width: CGFloat(w), height: CGFloat(h))
  }

  @_transparent
  public init(_ scalar: CGFloat) {
    self.init(width: scalar, height: scalar)
  }

  @_transparent
  public init(_ scalar: CGFloat.NativeType) {
    self.init(width: CGFloat(scalar), height: CGFloat(scalar))
  }

  @_transparent
  public init(floatLiteral value: CGFloat.NativeType) {
    self.init(value)
  }

  @_transparent
  public static func / (dividend: CGSize, divisor: CGFloat) -> CGSize {
    return .init(dividend.width / divisor, dividend.height / divisor)
  }

  @inlinable
  public func swapped() -> CGSize {
    return .init(height, width)
  }

  @inlinable
  public mutating func swap() -> () {
    (width, height) = (height, width)
  }
}

extension CGRect {

  public static let zero = CGRect()

  public init(
    x: CGFloat,
    y: CGFloat,
    w: CGFloat,
    h: CGFloat
  ) {
    self.init(x: x, y: y, width: w, height: h)
  }

  public init(
    _ x: CGFloat.NativeType,
    _ y: CGFloat.NativeType,
    _ w: CGFloat.NativeType,
    _ h: CGFloat.NativeType
  ) {
    self.init(
      x: CGFloat(x),
      y: CGFloat(y),
      width: CGFloat(w),
      height: CGFloat(h))
  }

  public init(origin: CGPoint, size: CGSize) {
    self.init(
      x: origin.x,
      y: origin.y,
      width: size.width,
      height: size.height)
  }

  public init(_ origin: CGPoint) {
    self.init(origin: origin, size: .zero)
  }

  public init(_ size: CGSize) {
    self.init(origin: .zero, size: size)
  }
}

#if os(iOS)
extension UIEdgeInsets {

  public init(
    _ top: CGFloat.NativeType,
    _ left: CGFloat.NativeType,
    _ bottom: CGFloat.NativeType,
    _ right: CGFloat.NativeType
  ) {
    self.init(
      top: CGFloat(top),
      left: CGFloat(left),
      bottom: CGFloat(bottom),
      right: CGFloat(right))
  }
}
#endif

// MARK: - Color

#if os(iOS)
extension CGColor {

  static let black     = UIColor.black.cgColor // 0.0 white
  static let darkGray  = UIColor.darkGray.cgColor // 0.333 white
  static let lightGray = UIColor.lightGray.cgColor // 0.667 white
  static let white     = UIColor.white.cgColor // 1.0 white
  static let gray      = UIColor.gray.cgColor // 0.5 white
  static let red       = UIColor.red.cgColor // 1.0, 0.0, 0.0 RGB
  static let green     = UIColor.green.cgColor // 0.0, 1.0, 0.0 RGB
  static let blue      = UIColor.blue.cgColor // 0.0, 0.0, 1.0 RGB
  static let cyan      = UIColor.cyan.cgColor // 0.0, 1.0, 1.0 RGB
  static let yellow    = UIColor.yellow.cgColor // 1.0, 1.0, 0.0 RGB
  static let magenta   = UIColor.magenta.cgColor // 1.0, 0.0, 1.0 RGB
  static let orange    = UIColor.orange.cgColor // 1.0, 0.5, 0.0 RGB
  static let purple    = UIColor.purple.cgColor // 0.5, 0.0, 0.5 RGB
  static let brown     = UIColor.brown.cgColor // 0.6, 0.4, 0.2 RGB
  static let clear     = UIColor.clear.cgColor // 0.0 white, 0.0 alpha

  public static func rgba(
    _ r: CGFloat,
    _ g: CGFloat,
    _ b: CGFloat,
    _ a: CGFloat
  ) -> CGColor {
    return UIColor(red: r, green: g, blue: b, alpha: a).cgColor
  }

  public static func rgb(
    _ r: CGFloat,
    _ g: CGFloat,
    _ b: CGFloat
  ) -> CGColor {
    return UIColor(red: r, green: g, blue: b, alpha: 1).cgColor
  }

  public static func white(
    _ w: CGFloat,
    alpha a: CGFloat
  ) -> CGColor {
    return UIColor(white: w, alpha: a).cgColor
  }
}

extension UIColor {

  public static func rgba(
    _ r: CGFloat,
    _ g: CGFloat,
    _ b: CGFloat,
    _ a: CGFloat
  ) -> UIColor {
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }

  public static func rgb(
    _ r: CGFloat,
    _ g: CGFloat,
    _ b: CGFloat
  ) -> UIColor {
    return UIColor(red: r, green: g, blue: b, alpha: 1)
  }

  public convenience init(
    r: CGFloat,
    g: CGFloat,
    b: CGFloat,
    a: CGFloat
  ) {
    self.init(red: r, green: g, blue: b, alpha: a)
  }

  public convenience init(
    r: CGFloat,
    g: CGFloat,
    b: CGFloat
  ) {
    self.init(red: r, green: g, blue: b, alpha: 1)
  }
}
#endif
