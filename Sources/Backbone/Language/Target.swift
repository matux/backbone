import Swift

public protocol TargetEnvironment { }
public struct Device: TargetEnvironment { fileprivate init() {} }
public struct Simulator: TargetEnvironment { fileprivate init() {} }

public protocol TargetConfiguration { }
public struct Debug: TargetConfiguration { fileprivate init() {} }
public struct NotDebug: TargetConfiguration { fileprivate init() {} }

public struct Target {

  /// A type identifying the compilation configuration.
  ///
  /// Enables using the preprocessor instruction as an expression, so:
  ///
  ///     #if DEBUG
  ///     print("Debug!")
  ///     #else
  ///     print("Not Debug!")
  ///     #endif
  ///
  /// Becomes:
  ///
  ///     print(Target.Configuration is Debug ? "Debug!" : "Not Debug!")
  public static let Configuration: TargetConfiguration = {
    #if DEBUG
    return Debug()
    #else
    return NotDebug()
    #endif
  }()

  public static let Environment: TargetEnvironment = {
    #if targetEnvironment(simulator)
    return Simulator()
    #else
    return Device()
    #endif
  }()
}
