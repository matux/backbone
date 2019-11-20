import struct Darwin.sys.qos.qos_class_t
import enum Foundation.NSObjCRuntime.QualityOfService
import Foundation
import Dispatch

public enum Dispatch {

  /// An object that manages the execution of tasks serially or concurrently on
  /// your app's main thread or on a background thread.
  ///
  /// Dispatch queues are **FIFO** queues to which your application can submit
  /// tasks in the form of block objects. Dispatch queues execute tasks either
  /// serially or concurrently. Work submitted to dispatch queues executes on a
  /// pool of threads managed by the system. **Except for the dispatch queue**
  /// **representing your app's main thread,** the system makes no guarantees
  /// about which thread it uses to execute a task.
  ///
  /// You schedule work items synchronously or asynchronously. When you schedule
  /// a work item synchronously, your code waits until that item finishes
  /// execution. When you schedule a work item asynchronously, your code
  /// continues executing while the work item runs elsewhere.
  ///
  /// - Important: Attempting to synchronously execute a work item on the main
  ///   queue results in **deadlock.**
//  public typealias Queue = DispatchQueue

////  MARK: typealias Queue

  /// An object that coordinates the processing of specific low-level system
  /// events, such as file-system events, timers, and UNIX signals.
  ///
  /// Use the methods of this class to construct new dispatch sources of the
  /// appropriate types.
  public typealias Source = DispatchSource

  // MARK: typealias Source

  /// An object that controls access to a resource across multiple execution
  /// contexts through use of a traditional counting semaphore.
  ///
  /// A dispatch semaphore is an efficient implementation of a traditional
  /// counting semaphore. Dispatch semaphores call down to the kernel only when
  /// the calling thread needs to be blocked. If the calling semaphore does not
  /// need to block, no kernel call is made.
  ///
  /// You increment a semaphore count by calling the [signal()][1] method, and
  /// decrement a semaphore count by calling [wait()][2] or one of its variants
  /// that specifies a timeout.
  ///
  /// [1]: https://developer.apple.com/documentation/dispatch/dispatchsemaphore/1452919-signal
  /// [2]: https://developer.apple.com/documentation/dispatch/dispatchsemaphore/2016071-wait
  public typealias Semaphore = DispatchSemaphore

  // MARK: typealias Semaphore

  /// Used to indicate the nature and importance of work to the system. Work
  /// with higher quality of service classes receive more resources than work
  /// with lower quality of service classes whenever there is resource
  /// contention.
  public typealias QualityOfService = Foundation.QualityOfService

  // MARK: typealias QualityOfService

  /// The quality of service, or the execution priority, to apply to tasks.
  ///
  /// A quality-of-service (QoS) class categorizes work to be performed on a
  /// [DispatchQueue][1]. By specifying the quality of a task, you indicate its
  /// importance to your app. When scheduling tasks, the system prioritizes
  /// those that have higher service classes.
  ///
  /// Because higher priority work is performed more quickly and with more
  /// resources than lower priority work, it typically requires more energy
  /// than lower priority work. Accurately specifying appropriate QoS classes
  /// for the work your app performs ensures that your app is responsive and
  /// energy efficient.
  ///
  /// [1]: https://developer.apple.com/documentation/dispatch/dispatchqueue
  public typealias QoS = DispatchQoS

  // MARK: typealias QoS

  /// Manages work items that must be dispatched only once per program's
  /// execution.
  public /*namespace*/ enum Once {

    fileprivate static var hashes = Set<Int>()
  }
}

// MARK: - Dispatch.Queue

protocol DispatchQueueRepresentable: RawRepresentable {

}

extension Dispatch {

}

extension DispatchQueue {

  /// Returns the `default` global system queue.
  ///
  /// This method returns a queue suitable for executing tasks with a `default`
  /// `QualityOfService` level. Calls to the `suspend()`, `resume()`, and
  /// `dispatch_set_context(_:_:)` functions have no effect on the returned
  /// queues.
  ///
  /// Tasks submitted to the returned queue are scheduled concurrently with
  /// respect to one another.
  @inlinable
  public static var global: DispatchQueue {
    global(qos: .default)
  }
}

// MARK: - Dispatch.Source

extension Dispatch.Source {

  /// A dispatch source that submits the event handler block based on a timer.
  ///
  /// You do not adopt this protocol in your objects. Instead, use the
  /// [makeTimerSource(flags:queue:)][1] method to create an object that adopts
  /// this protocol.
  ///
  /// [1]: https://developer.apple.com/documentation/dispatch/dispatchsource
  public typealias Timer = DispatchSourceTimer
}

// MARK: - Dispatch.Semaphore

extension Dispatch.Semaphore: SelfAware {

  fileprivate static let once = Self(value: .unit)
}

// MARK: - Darwin.qos_class_t

extension Darwin.qos_class_t: Hashable {

  /// Returns the requested QOS class of the current thread.
  ///
  /// - Returns: One of the QOS class values in `qos_class_t`.
  public static var current: Self { qos_class_self() }

  /// Returns the initial requested QOS class of the main thread.
  ///
  /// The QOS class that the main thread of a process is created with depends
  /// on the type of process (e.g. application or daemon) and on how it has
  /// been launched.
  ///
  /// This function returns that initial requested QOS class value chosen by
  /// the system to enable propagation of that classification to matching work
  /// not executing on the main thread.
  ///
  /// - Returns: One of the QOS class values in `qos_class_t`.
  public static var main: Self { qos_class_main() }
}

// MARK: - Dispatch.QualityOfService

extension Dispatch.QualityOfService: CustomStringConvertible {

  /// An unspecified QoS class, which defaults to a `.default` QoS class.
  public static let unspecified: Self = .default

  /// Returns the requested QOS class of the current thread.
  ///
  /// - Returns: One of the QOS class values in `qos_class_t`.
  public static var current: Self { .init(qos_class_t.current) }

  /// Returns the initial requested QOS class of the main thread.
  ///
  /// The QOS class that the main thread of a process is created with depends
  /// on the type of process (e.g. application or daemon) and on how it has
  /// been launched.
  ///
  /// This function returns that initial requested QOS class value chosen by
  /// the system to enable propagation of that classification to matching work
  /// not executing on the main thread.
  ///
  /// - Returns: One of the QOS class values in `qos_class_t`.
  public static var main: Self { .init(qos_class_t.main) }

  public var description: String {
    [
      .userInteractive: "↑",
      .userInitiated: "ꜛ",
      .default: "⁻",
      .utility:    "ꜜ",
      .background: "↓",
      .unspecified: "Ɂ"
    ][self] ?? "unknown"
  }

  /// Create a new instance of `QualityOfService` from the given QoS class
  /// object.
  ///
  /// - Parameter qosClass: The QoS class to base the instance of. Defaults to
  ///   the QoS in used by the current process.
  public init(_ qosClass: Darwin.qos_class_t) {
    self = [
      QOS_CLASS_USER_INTERACTIVE: .userInteractive,
      QOS_CLASS_USER_INITIATED: .userInitiated,
      QOS_CLASS_DEFAULT: .default,
      QOS_CLASS_UTILITY: .utility,
      QOS_CLASS_BACKGROUND: .background,
      QOS_CLASS_UNSPECIFIED: .unspecified
      ][qosClass] ?? .default
  }

  public init(_ qos: Dispatch.QoS) {
    switch qos {
    case .userInteractive: self = .userInteractive
    case .userInitiated: self = .userInitiated
    case .default: self = .default
    case .utility: self = .utility
    case .background: self = .background
    case .unspecified: self = .unspecified
    default: self = .default
    }
  }

  public init(_ klass: Dispatch.QoS.QoSClass) {
    switch klass {
    case .userInteractive: self = .userInteractive
    case .userInitiated: self = .userInitiated
    case .default: self = .default
    case .utility: self = .utility
    case .background: self = .background
    case .unspecified: self = .unspecified
    @unknown default: self = .default
    }
  }
}

// MARK: - Dispatch

extension Dispatch {

  /// Executes the given closure `fire` on the **main** queue  in the specified
  /// interval.
  ///
  /// - Tag: Dispatch.in
  @inlinable
  public static func `in`<UnitOfTime: UnitOfMeasurement>(
    _ delay: Measurement<UnitOfTime>,
    _ closure: @escaping () -> ()
  ) where UnitOfTime.Dimension == Time {
    DispatchQueue.main.asyncAfter(
      deadline: .now() + *delay,
      execute: closure)
  }

  /// Executes the given closure `fire` on a given `queue` in the specified
  /// interval _iff_ the given `condition` evaluates to `true` at the time of
  /// execution.
  ///
  /// - Tag: Dispatch.in
  @inlinable
  public static func `in`(
    _ delay: Measurement<Seconds>,
    on queue: DispatchQueue,
    if condition: @escaping () -> Bool? = { true },
    _ fire: @escaping () -> ()
  ) {
    queue.asyncAfter(
      deadline: .now() + *delay,
      execute: { when(condition(), isTrue, fire) })
  }

  /// Synchronously executes the given closure only once.
  ///
  /// The `once` function runs once and only once for any distinct call to it.
  ///
  /// - Important: The `once` function does **not** keep track of the given
  ///   closure; rather, it auto-logs calls to itself within itself.
  ///   Loggingception.
  ///
  /// - Parameter fire: The closure to execute only once.
  @inline(never)
  public static func once(
    from loc: SourceLoc = .init(fl: #file, fn: #function, ln: #line, col: #column),
    do fire: @escaping () -> ()
  ) {
    enum ·{ static var hashes = Set<Int>() }
    let insert = { _ = ·.hashes.insert($0) }

    Hasher()
      |> mutating(Hasher.combine(loc))
      |> Hasher.finalize
      |> unless(∈·.hashes, insert >>> fire)
  }
}

// Inspired by https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619

// MARK: -
// MARK: - Async

@inlinable
public func async(on queue: DispatchQueue, _ closure: @escaping () -> ()) -> () {
  queue.async(execute: closure)
}

@inlinable
public func async<A>(on queue: DispatchQueue, _ closure: @escaping (A) -> ()) -> (A) -> () {
  { x in queue.async { closure(x) } }
}

@inlinable
public func async<A, B>(on queue: DispatchQueue, _ closure: @escaping ((A, B)) -> ()) -> (A, B) -> () {
  { x, y in queue.async { closure((x, y)) } }
}

@inlinable
public func async<A, B, C>(on queue: DispatchQueue, _ closure: @escaping ((A, B, C)) -> ()) -> (A, B, C) -> () {
  { x, y, z in queue.async { closure((x, y, z)) } }
}

@inlinable
public func async<A, B, C, D>(on queue: DispatchQueue, _ closure: @escaping ((A, B, C, D)) -> ()) -> (A, B, C, D) -> () {
  { x, y, z, w in queue.async { closure((x, y, z, w)) } }
}

// MARK: Async (tacit)

/// Schedules a closure asynchronously for execution.
@inlinable
public func async(_ closure: @escaping () -> ()) -> () {
  DispatchQueue.main.async(execute: closure)
}

/// Schedules a unary closure and an argument asynchronously for execution.
@inlinable
public func async<A>(_ closure: @escaping (A) -> ()) -> (A) -> () {
  { x in DispatchQueue.main.async { closure(x) } }
}

/// Schedules a binary closure and two arguments asynchronously for execution.
@inlinable
public func async<A, B>(_ closure: @escaping ((A, B)) -> ()) -> (A, B) -> () {
  { x, y in DispatchQueue.main.async { closure((x, y)) } }
}

/// Schedules a ternary closure and three arguments asynchronously for execution.
@inlinable
public func async<A, B, C>(_ closure: @escaping ((A, B, C)) -> ()) -> (A, B, C) -> () {
  { x, y, z in DispatchQueue.main.async { closure((x, y, z)) } }
}

/// Schedules a quaternary closure and four arguments asynchronously for execution.
@inlinable
public func async<A, B, C, D>(_ closure: @escaping ((A, B, C, D)) -> ()) -> (A, B, C, D) -> () {
  { x, y, z, w in DispatchQueue.main.async { closure((x, y, z, w)) } }
}

// MARK: - Await

/// Schedules a closure for execution and suspends the current queue until it
/// completes.
@inlinable
public func await(for queue: DispatchQueue, _ closure: @escaping () -> ()) -> () {
  queue.sync(execute: closure)
}

/// Schedules a unary closure and an argument for execution and suspends the
/// current queue until it completes.
@inlinable
public func await<A>(for queue: DispatchQueue, _ closure: @escaping (A) -> ()) -> (A) -> () {
  { x in queue.sync { closure(x) } }
}

/// Schedules a binary closure and two arguments for execution and suspends the
/// current queue until it completes.
@inlinable
public func await<A, B>(for queue: DispatchQueue, _ closure: @escaping ((A, B)) -> ()) -> (A, B) -> () {
  { x, y in queue.sync { closure((x, y)) } }
}

/// Schedules a ternary closure and three arguments for execution and suspends
/// the current queue until it completes.
@inlinable
public func await<A, B, C>(for queue: DispatchQueue, _ closure: @escaping ((A, B, C)) -> ()) -> (A, B, C) -> () {
  { x, y, z in queue.sync { closure((x, y, z)) } }
}

/// Schedules a quaternary closure and four arguments for execution and suspends
/// the current queue until it completes.
@inlinable
public func await<A, B, C, D>(for queue: DispatchQueue, _ closure: @escaping ((A, B, C, D)) -> ()) -> (A, B, C, D) -> () {
  { x, y, z, w in queue.sync { closure((x, y, z, w)) } }
}

// MARK: Await (tacit)

@inlinable
public func await(_ closure: @escaping () -> ()) -> () {
  DispatchQueue.main.sync(execute: closure)
}

@inlinable
public func await<A>(_ closure: @escaping (A) -> ()) -> (A) -> () {
  { x in DispatchQueue.main.sync { closure(x) } }
}

@inlinable
public func await<A, B>(_ closure: @escaping ((A, B)) -> ()) -> (A, B) -> () {
  { x, y in DispatchQueue.main.sync { closure((x, y)) } }
}

@inlinable
public func await<A, B, C>(_ closure: @escaping ((A, B, C)) -> ()) -> (A, B, C) -> () {
  { x, y, z in DispatchQueue.main.sync { closure((x, y, z)) } }
}

@inlinable
public func await<A, B, C, D>(_ closure: @escaping ((A, B, C, D)) -> ()) -> (A, B, C, D) -> () {
  { x, y, z, w in DispatchQueue.main.sync { closure((x, y, z, w)) } }
}
