#if os(iOS)
import Foundation
import UIKit

@available(iOS 10.0, *)
extension UIViewAnimatingState: CustomStringConvertible {

  public var description: String {
    switch self {
    case .inactive: return "inactive"
    case .active: return "active"
    case .stopped: return "stopped"
    case let unknown: return "???(\(unknown.rawValue))"
    }
  }
}

@available(iOS 10.0, *)
extension UIViewAnimatingPosition: CustomStringConvertible {

  public var description: String {
    switch self {
    case .end: return "end"
    case .start: return "start"
    case .current: return "current"
    case let unknown: return "???(\(unknown.rawValue))"
    }
  }
}

@available(iOS 10.0, *)
extension UIViewPropertyAnimator/*: CustomStringConvertible*/ {

//  open override var description: String {
//      "\(type(of: self)): running(\(isRunning)) reversed(\(isReversed)), "
//        ++ "\(state), \(fractionComplete)"
//    }
}

extension UIViewAnimating {

  /// Starts the animation from its current position.
  ///
  /// Call this method to start the animations or to resume the animation
  /// after they were paused. This method sets the state of the animator to
  /// `active`, if it is not already there. **It is a programmer error** to
  /// call this method while the state of the animator is set to `stopped`.
  ///
  /// When implementing a custom animator, use this method to transition your
  /// animator to the `active` state and to run the animations. Run your
  /// animations from the progress point in the `fractionComplete` property.
  /// Update the `state` and `isRunning` properties, as well as any other
  /// relevant properties of your custom animator object.
  public func start() {
    startAnimation()
  }

  /// Starts the animation after the specified delay.
  ///
  /// Call this method to start the animations or to resume the animation
  /// after they were paused. This method sets the state of the animator to
  /// `active`, if it is not already there. **It is a programmer error** to
  /// call this method while the state of the animator is set to `stopped`.
  ///
  /// When implementing a custom animator, use this method to transition your
  /// animator to the `active` state and to run the animations. Run your
  /// animations from the progress point in the `fractionComplete` property.
  /// Update the `state` and `isRunning` properties, as well as any other
  /// relevant properties of your custom animator object.
  ///
  /// - Parameter delay: The amount of time (in seconds) to wait before starting
  ///   the animation.
  public func start(after delay: TimeInterval) {
    startAnimation(afterDelay: delay)
  }

  /// Pauses a running animation at its current position.
  ///
  /// This method pauses running animations at their current values. Calling
  /// this method on an `inactive` animator moves its state to `active` and
  /// puts its animations in a `paused` state right away.
  ///
  /// - Note: To resume the animations, call the `startAnimation()` method. If
  ///   the animation is already paused, this method should do nothing.
  ///
  /// - Important: **It is a programmer error to call** this method while the
  ///   state of the animator is set to `stopped`.
  public func pause() {
    pauseAnimation()
  }

  /// Stops the animations at their current positions.
  ///
  /// Call this method when you want to end the animations at their current
  /// position. This method removes all of the associated animations from the
  /// execution stack and sets the values of any animatable properties to their
  /// current values.
  ///
  /// Call the `finish(at:)` method to perform the animator’s final actions. For
  /// example, a `UIViewPropertyAnimator` object executes its `completion`
  /// blocks when you call this method.
  ///
  /// - Remark: You do not have to call the `finish(at:)` method right away, or
  ///   at all, and you can perform other animations before calling that method.
  public func stop() {
    stopAnimation(false)
  }

  /// Pauses a running animation at its current position.
  ///
  /// Call this method when you want to end the animations at their current
  /// position. This method removes all of the associated animations from the
  /// execution stack and sets the values of any animatable properties to their
  /// current values.
  ///
  /// - Note: This method also updates the state of the animator object.
  public func stop(at position: UIViewAnimatingPosition) {
    stopAnimation(true)
    finish(at: position)
  }

  /// Finishes the animations and returns the animator to the `inactive` state.
  ///
  /// After putting the animator object into the `stopped` state, call this
  /// method to perform any final cleanup tasks.
  ///
  /// - Warning: **It is a programmer error** to call this method at any time
  ///   except after a call to the `stop()` method.
  ///
  /// Calling this method is not required, but is recommended in cases where
  /// you want to ensure that `completion` blocks or other final tasks are
  /// performed.
  ///
  /// - Important: Implementations of this method are responsible for setting
  ///   the `state` of the `animator` object to `inactive` and for performing
  ///   any final cleanup tasks, such as executing `completion` blocks.
  ///
  /// - Parameter position: The final position for any view properties. Specify
  ///   `.current` to leave the view properties unchanged from their current
  ///   values.
  public func finish(at position: UIViewAnimatingPosition) {
    finishAnimation(at: position)
  }
}

extension UIViewImplicitlyAnimating {

  /// Adds the specified animation block to the animator.
  ///
  /// Use this method to add new animation blocks to your custom animator
  /// object. The animations in the specified block should run alongside any
  /// previously configured animations, starting at the current time and
  /// finishing at the same time as any original animations.
  ///
  /// - Important: Your implementation must be able to handle multiple calls
  ///   to this method.
  ///
  /// - Parameter animation: A block containing the animations to add to the
  ///   animator object. This block has no return value and takes no parameters.
  public func add(
    animation: @escaping () -> ()
  ) -> () {
    addAnimations?(animation)
  }

  /// Adds the specified animation block to the animator with a delay.
  ///
  /// Use this method to add new animation blocks to your custom animator
  /// object. The animations in the new block should run alongside any
  /// previously configured animations, starting after the specified delay and
  /// finishing at the same time as any original animations.
  ///
  /// - Important: Your implementation must be able to handle multiple calls to
  ///   this method.
  ///
  /// - Parameters:
  ///   - animation: A block containing the animations to add to the animator
  ///     object. This block has no return value and takes no parameters.
  ///   - delay: The factor to use for delaying the start of the animations. The
  ///     value must be between `0.0` and `1.0`. Multiply this value by the
  ///     animator’s remaining duration to determine the actual delay in
  ///     seconds. For example, if the value `0.5` and the animator’s duration
  ///     is `2.0`, delay the start of the animations by one second.
  public func add(
    animation: @escaping () -> (),
    delay: CGFloat
  ) -> () {
    addAnimations?(
      animation,
      delayFactor: delay)
  }

  /// Adds the specified completion block to the animator.
  ///
  /// Use this method to add the completion blocks to your custom animator
  /// object. Completion blocks should execute after the animations finish
  /// successfully. If the `finish(_:)` method is called, do not execute
  /// any completion blocks. If the `stop(_:)` method is called and the client
  /// subsequent calls the `finish(at:)` method, execute the `completion` blocks
  /// in your implementation of that method.
  ///
  /// - Important: Your implementation must be able to handle multiple calls to
  ///   this method.
  ///
  /// - Parameters:
  ///   - completion: A block to execute when the animations finish. This block
  ///     has no return value and takes the following parameter:
  ///   - finalPosition:
  ///     The position where the animations stopped. Use this value to specify
  ///     whether the animations stopped at their starting point, their end
  ///     point, or their current position.
  @available(iOS 10.0, *)
  public func add(
    completion: @escaping (_ finalPosition: UIViewAnimatingPosition) -> ()
  ) -> () {
    addCompletion?(completion)
  }

  /// Adjusts the final timing and duration of a paused animation.
  ///
  /// Use this method to change the `timing` and `duration` parameters for the
  /// current animations temporarily. You define the conditions for which it is
  /// safe to call this method, but **typically it is an error** to call this
  /// method on an animator that is `inactive`, `running`, or not interruptible.
  ///
  /// You should retain the original `timing` and `duration` values and restore
  /// them when your animator transitions back to the `inactive` state.
  ///
  /// - Parameters:
  ///   - curve: The new timing information to apply to the animation. Your
  ///     custom animator determines how to transition from any current
  ///     animations to the new animations specified by this parameter.
  ///   - duration: A multiplying factor to apply to the animation’s original
  ///     `duration`. Multiply this value by your animation’s original
  ///     `duration` value to obtain the new duration for the animations.
  public func `continue`(
    curve: UITimingCurveProvider?,
    duration: CGFloat
  ) -> () {
    continueAnimation?(
      withTimingParameters: curve,
      durationFactor: duration)
  }
}

#endif
