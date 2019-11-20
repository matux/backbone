import Foundation

extension Data {

  /// Creates a new instance of `Data` with the **UTF-8** representation of
  /// the given String.
  public init?(utf8Encoded string: String) {
    self.init(string, using: .utf8)
  }

  /// Creates a new instance of `Data` with the representation of the given
  /// String encoded using the specified encoding.
  public init?(_ string: String, using encoding: String.Encoding) {
    guard let data = string.data(using: encoding) else {
      return nil
    }
    
    self = data
  }
}
