#if canImport(UIKit) && !os(watchOS)
import UIKit

public protocol Fading {

  func fadeIn(
    duration: TimeInterval,
    delay: TimeInterval,
    andThen complete: @escaping () -> ())

  func fadeOut(
    duration: TimeInterval,
    delay: TimeInterval,
    andThen complete: @escaping () -> ())
}

extension Fading {

  @inlinable
  public func fadeIn() {
    fadeIn(andThen: noop)
  }

  @inlinable
  public func fadeOut() {
    fadeOut(andThen: noop)
  }

  
  @inlinable
  public func fadeIn(andThen complete: @escaping () -> ()) {
    fadeIn(duration: .default, delay: 0, andThen: complete)
  }

  @inlinable
  public func fadeOut(andThen complete: @escaping () -> ()) {
    fadeOut(duration: .short, delay: 0, andThen: complete)
  }

  @inlinable
  public static func fadeIn<T: Fading>(_ x: T) {
    x.fadeIn()
  }

  @inlinable
  public static func fadeOut<T: Fading>(_ x: T) {
    x.fadeOut()
  }

  @inlinable
  public static func fadeIn<T: Fading>(
    andThen complete: @escaping () -> ()
  ) -> (T) -> () {
    return { x in x.fadeIn(andThen: complete) }
  }

  @inlinable
  public static func fadeOut<T: Fading>(
    andThen complete: @escaping () -> ()
  ) -> (T) -> () {
    return { x in x.fadeOut(andThen: complete) }
  }
}

@inlinable
public func fadeIn<View: UIView>(
  andThen complete: @escaping (View) -> ()
) -> (View) -> () {
  return { view in view.fadeIn { complete(view) } }
}

@inlinable
public func fadeIn(view: UIView) -> () {
  return view.fadeIn(andThen: noop)
}

@inlinable
public func fadeOut<View: UIView>(
  andThen complete: @escaping (View) -> ()
) -> (View) -> () {
  return { view in view.fadeOut { complete(view) } }
}

@inlinable
public func fadeOut(view: UIView) -> () {
  return view.fadeOut(andThen: noop)
}

extension UIView: Fading {
  public typealias PropertyAnimator = UIViewPropertyAnimator

  @objc
  open func fadeIn(
    duration: TimeInterval,
    delay: TimeInterval,
    andThen complete: @escaping () -> ()
  ) {
    guard alpha.isZero else { return complete() }
    UIViewPropertyAnimator
      .runningPropertyAnimator(
        withDuration: duration,
        delay: delay,
        options: .curveEaseOut,
        animations: { self.alpha = 1 },
        completion: discard >>> complete)
  }

  @objc
  open func fadeOut(
    duration: TimeInterval,
    delay: TimeInterval,
    andThen complete: @escaping () -> ()
  ) {
    guard alpha.isUnit else { return complete() }
    UIViewPropertyAnimator
      .runningPropertyAnimator(
        withDuration: duration,
        delay: delay,
        options: .curveEaseIn,
        animations: { self.alpha = 0 },
        completion: discard >>> complete)
  }
}

// MARK: - View collections

//extension Array: Fading where Element: UIView {
extension BidirectionalCollection
  where Self: Fading, Element: UIView, Self.Index: BinaryInteger
{
  public func fadeIn(
    duration: TimeInterval,
    delay: TimeInterval,
    andThen complete: @escaping () -> ()
  ) {
    guard case let Δ = .default / (.init(count) * 1.75), Δ ≥ .zero else {
      return complete()
    }

    enumerated().forEach { ι, view in
      view.fadeIn(
        duration: .default,
        delay: delay + Δ * .init(ι),
        andThen: ι == lastIndex! ? complete : noop)
    }
  }

  public func fadeOut(
    duration: TimeInterval,
    delay: TimeInterval,
    andThen complete: @escaping () -> ()
  ) {
    guard case let Δ = .short / (.init(count) * 1.75), Δ ≥ .zero else {
      return complete()
    }

    enumerated().forEach { ι, view in
      view.fadeOut(
        duration: .short,
        delay: delay + Δ * .init(ι),
        andThen: ι == lastIndex! ? complete : noop)
    }
  }
}

extension Array: Fading where Element: UIView { }
//extension Set: Fading where Element: UIView { }

@inlinable
public func fadeIn<View: UIView>(
  andThen complete: @escaping () -> ()
) -> ([View]) -> () {
  return { $0.fadeIn(andThen: complete) }
}

@inlinable
public func fadeIn(views: [UIView]) -> () { views.fadeIn() }

@inlinable
public func fadeOut<View: UIView>(
  andThen complete: @escaping () -> ()
) -> ([View]) -> () {
  return { $0.fadeOut(andThen: complete) }
}

@inlinable
public func fadeOut(views: [UIView]) -> () { views.fadeOut() }

#endif // canImport(UIKit) && !os(watchOS)
