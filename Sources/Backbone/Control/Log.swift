import Swift

#if RELEASE

@_transparent
@_optimize(speed)
@_effects(readnone)
public func log<T, U>(_ λ: @escaping (T) -> U) -> (T) -> U {
  return λ
}

@_transparent
@_optimize(speed)
@_effects(readnone)
public func trace(_: Any = ()){ }

@inline(__always)
public let print = discard • T<String>.in

@inline(__always)
public let debugPrint = discard • T<String>.in

#elseif DEBUG || PROFILE

// swiftlint:disable implicitly_unwrapped_optional + redundant_void_return + let_var_whitespace
import func CoreFoundation.CFAbsoluteTimeGetCurrent
import class Foundation.NSObject
import Darwin

/// Returns the given function with a logger attached that prints the arguments
/// and the result when the given function is called.
public func log<Input, Output>(
  _ λ: @escaping (Input) -> Output,
  fl: String = #file,
  ln: Int = #line,
  fn: String = #function
) -> (Input) -> Output {
  return apply({ input in { output in
    const(output)(print("\(input) -> \(output)", fl: fl, ln: ln, fn: fn))
  } }, λ)
}

@_transparent
public func trace(
  _ s: String = "",
  fl: String = #file,
  ln: Int = #line,
  fn: String = #function
) {
  print("[TRACE] \(fn) \(s)", fl: fl, ln: ln, fn: fn)
}

/// Writes the given string to the standard output.
@_transparent
public func print(
  _ s: String,
  fl: String = #file,
  ln: Int = #line,
  fn: String = #function
) {
  _print(s, "\(fl)", ln, "\(fn)", { Swift.print($0) })
}

/// Writes the given string to the standard output.
@_transparent
public func debugPrint(
  _ s: String, fl: StaticString = #file, ln: Int = #line, fn: StaticString = #function
) {
  _print(s, "\(fl)", ln, "\(fn)", { Swift.debugPrint($0) })
}

#if _runtime(_ObjC)

@objc
public final class Log: NSObject {

  /// Writes the given string to the standard output.
  @objc
  public static func print(_ s: String, fl: String, ln: Int, fn: String) {
    _print(s, fl, ln, fn, { Swift.print($0) })
  }
}

#endif

@usableFromInline
internal func _print(
  _ s: String,
  _ file: String,
  _ line: Int,
  _ function: String,
  _ print: (Any) -> ()
) {
  Swift.print("\(prefix)│\(infix(file, line, function))│\(s)")
}

// MARK: - Profile

public func benchmark(_ label: String = "∆", _ λ: () -> ()) {
  let time = const(now)(λ()) - now
  print("\(label) ⟶ \(time)ms")
}

public func benchmark2(title: String, λ: () -> ()) {
  λ() // warmup
  let start = CFAbsoluteTimeGetCurrent()
  for _ in 0..<1 { λ() }
  let time =  (CFAbsoluteTimeGetCurrent() - start) * 1000
  print("\(title): \(time, format: "%.3f")ms")
}

// MARK: - Private parts (low level)

import func ObjectiveC.pthread_threadid_np

private let initialTime = now

private var prefix: String {
  return .zero
    => mutating { ptid(&$0) }
    => { "\($0 & 0xfff, format: "%03x")" }
    => { "░▒▓█ \(time):\($0):\(qos_class_self().rawValue)"
  }
}

private func infix(_ path: String, _ line: Int,_ λ: String) -> String {
  let λ = (λ.contains(" ") ? λ.suffix(following: " ") : λ[...])
    .prefix(while: not • ["(", "]"].contains)
  return path
    .suffix(while: not • equals("/"))
    .prefix(upTo: ".")
    .appending(":\(line):\(λ)")
    .padded(width: 24)
}

/// The unchanging "now". If you get any errors or unexpecting results from
/// using this value, it's because your assumptions about the nature of time
/// are wrong.
///
/// I have a proof of this, but the margin isn't large enough to contain it.
@_transparent
private var now: UInt64 {
  if #available(OSX 10.12, *) {
    return ((mach_continuous_time() &* timebase) &>> 6 &* 0x10c7) &>> 26
  } else {
    return 0
  }
}

private let timebase: UInt64 = {
  var timebase = mach_timebase_info()
  mach_timebase_info(&timebase)
  return .init(timebase.numer / timebase.denom)
}()

@_transparent
private var time: String {
  secmsec() => {
    "\("\($0)".leftPadded(width: 3, with: "0")).\("\($1)".leftPadded(width: 3, with: "0"))"
  }
}

@_transparent
@inline(__always)
@_effects(readonly)
private func secmsec() -> (sec: UInt64, msec: UInt64) {
  // Instead of dividing nanoseconds by NSEC_PER_MSEC we operate on the integer as follows:
  // 1000000=2⁶×15625 ∴ ℕ≫6÷15625 ∧ 1÷15625=0.000064 ≈ 4295÷2²⁶=0.00006400048733⋯ ∴ (ℕ≫6×4295)≫26 ∎
  let instant = now &- initialTime
  // Extracting seconds from milliseconds is a similar operation:
  // 1000=2³×125 ∴ ℕ≫3÷125 ∧ 1÷125=0.008 ≅ 67109÷2²³=0.008000016212⋯ ∴ (ℕ≫3×67109)≫23 ∎
  let sec = (instant &>> 3 &* 0x10625) &>> 23 // ⟨⟩2.00µs ⌞1.33µs⌟ ⌜∧3.38µs⌝ σ0.50µs
  let msec = instant &- sec &* 1000 // ⟨⟩1.84µs ⌞1.29µ⌟s ⌜3.17µs⌝ σ0.42µs
  return (sec, msec)
}

/// Returns the current thread's system-wide unique id.
///
/// - Parameters:
///   - ptid: Pointer to a `UInt64`-sized mutable memory location.
/// - Returns: `0` on success, otherwise an error number.
@discardableResult
private func ptid(
  _ ptid: inout UInt64
) -> Int32 {
  pthread_threadid_np(.none, &ptid) // pthread_self ?
}

#endif // DEBUG || PROFILE
