#if os(iOS)
import UIKit

extension UIViewController {

  /// Presents a modal view controller with a standard transition animation.
  ///
  /// - Parameter vc: The view controller to display over the
  ///   current view controller’s content.
  public func present(_ vc: UIViewController) {
    present(vc, animated: true, completion: .none)
  }

  /// Presents a modal view controller with a standard transition animation.
  ///
  /// - Parameter vc: The view controller to display over the
  ///   current view controller’s content.
  public func present(_ vc: UIViewController, completion: @escaping () -> ()) {
    present(vc, animated: true, completion: completion)
  }

  /// Dismisses the view controller that was presented modally by the view
  /// controller.
  ///
  /// The _presenting_ view controller is responsible for dismissing the view
  /// controller it presented. If you call this method on the _presented_ view
  /// controller itself, `UIKit` asks the _presenting_ view controller to handle
  /// the dismissal.
  ///
  /// If you present _several_ view controllers in succession, thus building a
  /// stack of presented view controllers, calling this method on a view
  /// controller lower in the stack dismisses its immediate child view
  /// controller and all view controllers above that child on the stack. When
  /// this happens, only the top-most view is dismissed in an animated fashion;
  /// any intermediate view controllers are simply removed from the stack. The
  /// top-most view is dismissed using its modal transition style, which may
  /// differ from the styles used by other view controllers lower in the stack.
  ///
  /// If you want to retain a reference to the view controller's presented view
  /// controller, get the value in the `presentedViewController` property before
  /// calling this method.
  ///
  /// To be notified when the view controller finishes dismissing, use the
  /// `dismiss(animated:, completion:)` function.
  public func dismiss() {
    dismiss(animated: false, completion: .none)
  }

  // MARK: Static thunks

  /// Presents a modal view controller with a standard transition animation.
  ///
  /// - Parameter vc: The view controller to display over the
  ///   current view controller’s content.
  public static func present(
    _ vc: UIViewController
  ) -> (UIViewController) -> () {
    return { $0.present(vc) }
  }

  /// Presents a modal view controller with a standard transition animation.
  ///
  /// - Parameter vc: The view controller to display over the
  ///   current view controller’s content.
  public static func present(
    _ vc: UIViewController,
    completion: @escaping () -> ()
  ) -> (UIViewController) -> () {
    return { $0.present(vc, completion: completion) }
  }

  /// Dismisses the view controller that was presented modally by the view
  /// controller.
  public static func dismiss(
    _ vc: UIViewController
  ) -> () {
    dismiss(vc)()
  }
}

extension UIViewController {

  /// Returns the `UIView` instance subview whose `tag` matches the specified
  /// value.
  ///
  /// This method searches this view controller's subviews recursively for the
  /// specified view.
  ///
  /// - Parameter tag: The `tag` value to search for.
  /// - Returns: The view in the receiver’s hierarchy whose `tag` property
  ///   matches the value in the `tag` parameter.
  public func subview<View: UIView>(tagged tag: Int) -> View? {
    view.viewWithTag(tag).flatMap(T.cast)
  }

  /// Returns the `UILabel` instance whose `tag` matches the specified value.
  ///
  /// This method searches this view controller's subviews recursively for the
  /// specified `UILabel` instance.
  ///
  /// - Parameter tag: The `tag` value to search for.
  /// - Returns: The label in the receiver’s hierarchy whose `tag` property
  ///   matches the value in the `tag` parameter.
  public func label(tagged tag: Int) -> UILabel? {
    view.viewWithTag(tag).flatMap(T.cast)
  }
}

#endif
