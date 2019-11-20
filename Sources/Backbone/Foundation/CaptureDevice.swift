import AVFoundation

@available(OSX 10.14, *)
extension AVAuthorizationStatus: CustomStringConvertible {

  public enum Error: Swift.Error {
    case
      access(AVMediaType, AVAuthorizationStatus)
  }

  public var description: String {
    switch self {
    case .authorized: return "authorized"
    case .denied: return "denied"
    case .notDetermined: return "notDetermined"
    case .restricted: return "restricted"
    @unknown default:
      return "??"
    }
  }

  public static let status = AVCaptureDevice.authorizationStatus(for:)
}

@available(OSX 10.14, *)
extension AVCaptureDevice {

  public static func requestAccess(
    for media: AVMediaType,
    andThen notify: @escaping (Result<(), AVAuthorizationStatus.Error>) -> ()
  ) -> () {
    requestAccess(for: media, completionHandler:
      either(async { notify(.success) },
         or: async { notify(.failure(.access(media, .status(media)))) }))
  }
}
