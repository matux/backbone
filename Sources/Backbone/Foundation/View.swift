#if canImport(UIKit) && !os(watchOS)
import UIKit

extension NSLayoutConstraint.Attribute {

  /// A synonym of `.notAnAttribute`.
  ///
  /// A placeholder value that is used to indicate that the constraint’s
  /// _second item_ and _second attribute_ are **not** used in any
  /// calculations.
  ///
  /// Use this value when creating a constraint that assigns a constant to an
  /// attribute, for example:
  ///
  ///     item1.height >= 40
  ///
  /// - Note: If a constraint only has **one item**, set the **second item** to
  /// `nil`, and set the **second attribute** to `.none`.
  public static let none = Self.notAnAttribute
}

extension Sequence where Element: UIView {

  public func recurse(until predicate: (UIView) -> Bool) -> UIView? {
    lazy.compactMap {
      predicate($0) ? $0 : $0.subviews.recurse(until: predicate)
    }.first
  }

  public func recurse<U: UIView>(until type: U.Type) -> U? {
    lazy.compactMap { T.cast($0) ?? $0.subviews.recurse(until: type) }.first
  }
}

extension UIView {

  /// A Boolean value that determines whether the view is visible.
  ///
  /// This function checks both `isHidden` and `alpha`, which is more
  /// conducive to how humans express themselves.
  @inlinable
  public var isVisible: Bool {
    get { !(isHidden || alpha.isAlmostZero) }
    set { isHidden.toggle() }
  }

  @IBInspectable
  public var maskImage: UIImage? {
    get { T<UIImageView>.cast(mask)?.image }
    set { mask = newValue.map(UIImageView.init • ^\.template) }
  }
}

extension UIView {

  /// The radius of the view layer's corners
  @IBInspectable
  public var cornerRadius: CGFloat {
    get { return layer.cornerRadius }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = !newValue.isZero
      clipsToBounds = layer.masksToBounds
    }
  }

  @IBInspectable
  public var maskedCorners: CGRect {
    get {
      return layer.maskedCorners.contains >>> either(1, or: 0) |> {
        .init($0(.layerMinXMinYCorner), $0(.layerMaxXMinYCorner),
              $0(.layerMaxXMaxYCorner), $0(.layerMinXMaxYCorner))
      }
    }
    set(corners) {
      layer.maskedCorners = [
        corners.minX ≈≈ 0 ? [] : .layerMinXMinYCorner,
        corners.minY ≈≈ 0 ? [] : .layerMaxXMinYCorner,
        corners.width ≈≈ 0 ? [] : .layerMaxXMaxYCorner,
        corners.height ≈≈ 0 ? [] : .layerMinXMaxYCorner]
    }
  }

  /// The width of the view layer's border
  @IBInspectable
  public var borderWidth: CGFloat {
    get { return layer.borderWidth }
    set { layer.borderWidth = newValue }
  }

  /// The color of the view layer's border
  @IBInspectable
  public var borderColor: CGColor {
    get { return layer.borderColor ?? .clear  }
    set { layer.borderColor = newValue }
  }
}

// MARK: -
// MARK: - Static thunks

extension UIView {

  /// Unlinks the view from its `superview` and its `window`, and removes it
  /// from the responder chain.
  ///
  /// If the view `superview` is not `nil`, the `superview` releases the view.
  ///
  /// Calling this method removes any constraints that refer to the view you
  /// are removing, or that refer to any view in the subtree of the view you
  /// are removing.
  ///
  /// - Important: Never call this method from inside your view’s `draw(_:)`
  ///   method.
  public static func removeFromSuperview(_ view: UIView) -> () {
    view.removeFromSuperview()
  }
}

// MARK: -
// MARK: - Free thunks

/// Unlinks the view from its `superview` and its `window`, and removes it
/// from the responder chain.
///
/// If the view `superview` is not `nil`, the `superview` releases the view.
///
/// Calling this method removes any constraints that refer to the view you
/// are removing, or that refer to any view in the subtree of the view you
/// are removing.
///
/// - Important: Never call this method from inside your view’s `draw(_:)`
///   method.
public func removeFromSuperview(_ view: UIView) -> () {
  view.removeFromSuperview()
}

#endif // canImport(UIKit) && !os(watchOS)
