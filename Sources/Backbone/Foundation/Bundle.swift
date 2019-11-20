import Foundation

extension Bundle {

  public enum ResourceFormat {
    case plist, json, xml, strings, stringDict
  }

  public enum InfoDictionaryKey: Hashable {
    case identifier
    case name
    case executable
    case version
    case shortVersion
    case infoDictionaryVersion
    case localizations
    case developmentRegion
    case unsafe(key: String)

    fileprivate var rawValue: String {
      switch self {
      case .unsafe(let key): return key
      case .identifier: return .init(kCFBundleIdentifierKey)
      case .name: return .init(kCFBundleNameKey)
      case .executable: return .init(kCFBundleExecutableKey)
      case .version: return .init(kCFBundleVersionKey)
      case .shortVersion: return "CFBundleShortVersionString"
      case .infoDictionaryVersion: return .init(kCFBundleInfoDictionaryVersionKey)
      case .localizations: return .init(kCFBundleLocalizationsKey)
      case .developmentRegion: return .init(kCFBundleDevelopmentRegionKey)
      }
    }
  }

  /// Convenience that returns the **main** bundle identifier.
  public static let identifier = main.bundleIdentifier !! "missing bundle id"

  /// Convenience that returns the **main** bundle name.
  public static var name: String = main[.name] !! "missing bundle name"

  public subscript<Inferred>(key: InfoDictionaryKey) -> Inferred {
    return key.rawValue
      => object(forInfoDictionaryKey:) !! "No object under \(key)"
      => Type.cast !! "Object for \(key) is not a \(Inferred.self)"
  }

  public static func string(for key: InfoDictionaryKey) -> String {
    return main[key]
  }

  public func path(for type: ResourceFormat, named name: String) -> String? {
    return path(forResource: name, ofType: "\(type)")
  }
}
