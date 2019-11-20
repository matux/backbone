import QuartzCore

extension CALayer {

  /// Add the specified animation object to the layer’s render tree.
  ///
  /// If `duration` is ≤ `0`, it is changed to the current value of the
  /// `kCATransactionAnimationDuration` transaction property if set,
  /// otherwise to the default value of `0.25` seconds.
  ///
  /// - Parameters:
  ///   - animation: The animation to be added to the render tree. This object
  ///     is **copied** by the render tree, not referenced. Therefore,
  ///     subsequent modifications to the object are **not** propagated into
  ///     the render tree.
  @inlinable
  public func add(animation: CAAnimation) {
    add(animation, forKey: .none)
  }

  /// Returns the animation object with the specified identifier.
  ///
  /// - Attention: You must **not** modify any properties of the returned
  ///   object. Doing so will result in **undefined behavior**. You've been
  ///   warned...
  ///
  /// - Parameter key: A unique `String` that identifies an animation. This
  ///   `String` corresponds to the one passed to `addAnimation(_:)`.
  /// - Returns: The `CAAnimation` matching the identifier, or `.none` if no
  ///   such animation exists.
  @inlinable
  public func animation(for key: String) -> CAAnimation? {
    animation(forKey: key)
  }
}

// MARK: - Static thunks

extension CALayer {

  /// Add the specified animation object to the layer’s render tree.
  ///
  /// If `duration` is ≤ `0`, it is changed to the current value of the
  /// `kCATransactionAnimationDuration` transaction property if set,
  /// otherwise to the default value of `0.25` seconds.
  ///
  /// - Parameters:
  ///   - animation: The animation to be added to the render tree. This object
  ///     is **copied** by the render tree, not referenced. Therefore,
  ///     subsequent modifications to the object are **not** propagated into
  ///     the render tree.
  public static let addAnimation = flip(curry(CALayer.add))(nil)

  /// Returns the animation object with the specified identifier.
  ///
  /// - Attention: You must **not** modify any properties of the returned
  ///   object. Doing so will result in **undefined behavior**. You've been
  ///   warned...
  ///
  /// - Parameter key: A unique `String` that identifies an animation. This
  ///   `String` corresponds to the one passed to `addAnimation(_:)`.
  /// - Returns: The `CAAnimation` matching the identifier, or `.none` if no
  ///   such animation exists.
  @inlinable
  public static func animation(for key: String) -> (CALayer) -> CAAnimation? {
    return { layer in layer.animation(forKey: key) }
  }

  /// Remove all animations attached to the layer.
  ///
  /// - Parameter layer: The layer from where to remove all the animations.
  @inlinable
  public static func removeAllAnimations(from layer: CALayer) -> () {
    return layer.removeAllAnimations()
  }
}

extension CALayer {

  /// Appends the layer to the layer’s list of sublayers.
  ///
  /// If the `Array` in the `sublayers` property is `.none`, calling this
  /// method creates an `Array` for that property and adds the specified
  /// `layer` to it.
  /// _ _ _
  ///
  /// ### Parameters
  /// `layer` The layer to be added.
  public static let addSublayer = flip(CALayer.addSublayer)

  /// Detaches the given `layer` from its `superlayer`.
  ///
  /// You can use this method to remove a `layer` (and all of its sublayers)
  /// from a layer hierarchy. This method updates both the `superlayer` list of
  /// `sublayers` and sets the `layer` `superlayer` property to `.none`.
  ///
  /// - Parameter layer: The layer to remove from the hierarchy.
  public static func removeFromSuperlayer(_ layer: CALayer) {
    layer.removeFromSuperlayer()
  }
}
