#if os(iOS)
import Foundation
import UIKit

/// Closure event initialization for UIBarButtonItem.
///
/// Example:
///     navigationItem.rightBarButtonItem =
///       .init(image: image, style: .bordered) { btn in
///         print("Button \(btn) tapped.")
///       }
extension UIBarButtonItem: SelfAware {

  private final class Bag {
    static var key = 0 as UInt8
    let action: (Self) -> ()
    let item: Self

    init(item: Self, action: @escaping (Self) -> ()) {
      self.item = item
      self.action = action
    }

    @objc
    fileprivate func perform() {
      action(item)
    }
  }

  private var closure: Bag? {
    get { return Runtime.value(in: self, under: &Bag.key) }
    set(x) { Runtime.associate(x, with: self, under: &Bag.key, as: .nonatomicRetain) }
  }

  /// Initializes an `UIBarButtonItem` that will call the given closure when
  /// the button is touched.
  ///
  /// - Parameters:
  ///   - image: The item’s image. If `nil` an image is not displayed.
  ///   - style: The style of the item. One of the constants defined in
  ///     `UIBarButtonItemStyle`.
  ///   - handler: The closure which handles button touches.
  public convenience init(
    image: UIImage?,
    style: Style,
    action: @escaping (Self) -> ()
  ) {
    self.init(
      image: image,
      style: style,
      target: .none,
      action: #selector(Bag.perform))
    closure = .init(item: self, action: action)
    target = self
  }

  /// Initializes an `UIBarButtonItem` that will call the given closure when
  /// the butteon is touched.
  ///
  /// - Parameters:
  ///   - image:  The custom view for the item.
  ///   - action: A function to handle taps.
  public convenience init(
    customView: UIView,
    action λ: @escaping (Self) -> ()
  ) {
    self.init(customView: customView)
    closure = .init(item: self, action: λ)
    target = closure
    action = #selector(Bag.perform)
  }

  /// Initializes a new item containing the specified system item.
  ///
  /// - Parameters:
  ///   - item: The system item to use as the first item on the bar. One of the
  ///     constants defined in `UIBarButtonItem.SystemItem`.
  ///   - action: A function to handle taps.
  public convenience init(
    _ item: SystemItem,
    action: @escaping (Self) -> ()
  ) {
    self.init(
      barButtonSystemItem: item,
      target: .none,
      action: #selector(Bag.perform))
    closure = .init(item: self, action: action)
    target = self
  }
}

#endif
