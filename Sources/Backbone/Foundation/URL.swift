//swiftlint:disable force_unwrapping
import Foundation
#if os(iOS)
import class UIKit.UIApplication
#endif

/// A type-safe Map of HTTP header fields and values.
public typealias HTTPHeaders = [HTTPField: String]

/// An unsafe Map for additional custom HTTP fields and values.
public typealias HTTPRawHeaders = [HTTPField.RawValue: String]

extension URL: ExpressibleByStringLiteral {

  #if os(iOS)
  public static let deviceSettings = URL(for: .deviceSettings)
  #endif

  public enum Purpose: UInt {

    @usableFromInline
    var searchPath: FileManager.SearchPathDirectory {
      FileManager.SearchPathDirectory(rawValue: rawValue)!
    }

    /// Root directory where the application was installed
    case application = 1

    #if os(iOS)
    /// Symbolic URL to the device's settings screen.
    case deviceSettings = 1001
    #endif

    /// App sandbox directory where to store *Application Support* data
    /// such as, generated data files, configuration, templates, or other
    /// resources that are managed by the app.
    ///
    /// Backed up by iTunes and iCloud.
    ///
    ///     ~/Library/Application Support/:bundleIdentifier/**
    /// ---
    /// **See also** --- [The Library Directory](https://goo.gl/USvVYX)
    case applicationSupport = 14

    /// App sandbox directory where to store user-generated content. Backed
    /// up by iTunes and iCloud. Located at `~/Documents/**`
    ///
    /// This directory is _exposed to the user_ through file sharing
    /// therefore, avoid storing any data you don't want exposed to the
    /// user.
    ///
    /// ### See also —
    /// - [iOS Standard Directories](https://goo.gl/nVfowY)
    case documents = 9

    /// App sandbox directory where to store custom data files, such as
    /// caches, databases, resources, preferences.
    ///
    /// Backed up by iTunes and iCloud --- *except for the Caches subdir*.
    ///
    ///     ~/Library/**
    /// ---
    /// **See also** --- [The Library Directory](https://goo.gl/hWgjKN)
    case library = 5

    /// App sandbox directory where to store non-essential cache data that
    /// your app can re-create easily.
    ///
    ///     ~/Library/Caches/:bundleIdentifier/**
    /// ---
    /// **See also** --- [The Library Directory](https://goo.gl/USvVYX)
    case caches = 13

    /// App sandbox directory to write temporary files that do not need to
    /// persist between launches of your app. Purged by the system when the
    /// app is not running.
    ///
    ///     ~/tmp/**
    /// ---
    /// **See also** --- [iOS Standard Directories](https://goo.gl/nVfowY)
    case temporary = 1000
  }

  public init(for purpose: Purpose) {
    switch purpose {
    #if os(iOS)
    case .deviceSettings:
      self = URL(string: UIApplication.openSettingsURLString)!
    #endif
    case .temporary:
      self = URL(string: NSTemporaryDirectory())!
    default:
      self = FileManager.default.url(
        for: purpose.searchPath,
        in: .userDomainMask)

      switch purpose {
      case .applicationSupport, .caches:
        appendPathComponent(Bundle.main.bundleIdentifier !! "missing bundle id")
      case .application:
        deleteLastPathComponent()
      default: ()
      }

      if !FileManager.default.fileExists(atPath: path) {
        FileManager.default.create(directory: self)
      }
    }
  }

  /// Creates a file URL for the resource file identified by the
  /// specified path relative to given bundle.
  ///
  /// - Parameter path: A path to a file relative to the given
  ///   bundle's location.
  /// - Returns: The file URL for the resource file in the given
  ///   bundle or `nil` if the file could not be located.
  @inlinable
  public init(resource path: StaticString, in bundle: Bundle = .main) {
    guard let url =  URL(fileURLWithPath: "\(path)") |> {
      bundle.url(
        forResource: $0.deletingPathExtension().lastPathComponent,
        withExtension: $0.pathExtension,
        subdirectory: $0.deletingLastPathComponent().path)
    } else {
      preconditionFailure("Static resource \(path) not found in bundle \(bundle)")
    }

    self = url
  }

  @_transparent
  public init(stringLiteral: StaticString) {
    self = URL(string: "\(stringLiteral)") !! "Path malformed."
  }

  @_transparent
  @available(OSX 10.11, *)
  public init(file path: String) {
    self.init(
      fileURLWithPath: path,
      isDirectory: false,
      relativeTo: .none)
  }

  @_transparent
  @available(OSX 10.11, *)
  public init(file path: String, base: String) {
    self.init(
      fileURLWithPath: path,
      isDirectory: false,
      relativeTo: URL(directory: base))
  }

  @_transparent
  @available(OSX 10.11, *)
  public init(directory path: String) {
    self.init(
      fileURLWithPath: path,
      isDirectory: true,
      relativeTo: .none)
  }

  @_transparent
  @available(OSX 10.11, *)
  public init(directory path: String, base: String) {
    self.init(
      fileURLWithPath: path,
      isDirectory: true,
      relativeTo: URL(directory: base))
  }

  /// Replaces the path extension on self with the given path extension.
  ///
  /// - Precondition: The URL must have a path, otherwise, if the path is
  ///   empty (e.g., http://www.example.com), then this function will leave
  ///   the URL unchanged.
  /// - Parameter newPathExtension: The new path extension.
  /// - Returns: A new URL with the path extension replaced or the URL
  ///   unchanged.
  @inlinable
  public mutating func replacePathExtension(with pathExtension: String) {
    deletePathExtension()
    appendPathExtension(pathExtension)
  }

  /// Returns a URL constructed by replacing the path extension on self
  /// with the given path extension.
  ///
  /// - Precondition: The URL must have a path, otherwise, if the path is
  ///   empty (e.g., http://www.example.com), then this function will return
  ///   the URL unchanged.
  /// - Parameter newPathExtension: The new path extension.
  /// - Returns: A new URL with the path extension replaced or the URL
  ///   unchanged
  @inlinable
  public func replacingPathExtension(with pathExtension: String) -> URL {
    deletingPathExtension().appendingPathExtension(pathExtension)
  }
}

extension FileManager {

  /// Creates a directory at the specified URL creating any necessary
  /// intermediate directories.
  ///
  /// Directories are created according to the umask of the process.
  ///
  /// This method throws if a failure occurs at any stage of the operation.
  fileprivate func create(directory url: URL) {
    try! createDirectory(
      at: url,
      withIntermediateDirectories: true,
      attributes: .none)
  }

  /// Allows specifying a specific directory for a particular purpose.
  fileprivate func url(
    for directory: SearchPathDirectory,
    in domain: SearchPathDomainMask
  ) -> URL {
    try! url(
      for: directory,
      in: domain,
      appropriateFor: .none,
      create: false)
  }
}

extension URLRequest {

  /// A `Dictionary` containing all of the HTTP header fields for a request.
  ///
  /// Certain header fields are reserved (see [Reserved HTTP Headers][1]). Do
  /// **not** use this property to set such headers.
  ///
  /// [1]: https://developer.apple.com/documentation/foundation/nsurlrequest#1776617
  public var headers: [HTTPField: String] {
    get { allHTTPHeaderFields.else(.empty).compactMapKeys(HTTPField.init) }
    set { allHTTPHeaderFields = newValue.mapKeys(^\.rawValue) }
  }

  /// Sets a value for a header field.
  ///
  /// The new value for the header field will replace any existing value for
  /// the field.
  ///
  /// If the length of your upload body data can be determined automatically
  /// (for example, if you provide the body content with a NSData object), then
  /// the value of Content-Length is set for you.
  ///
  /// - Parameter field: The name of the header field to set. In keeping with
  ///   the HTTP RFC, HTTP header field names are case-insensitive.
  @inlinable
  public subscript(_ field: HTTPField) -> String? {
    get { allHTTPHeaderFields?[field.rawValue] }
    set { setValue(newValue, forHTTPHeaderField: field.rawValue) }
  }

  /// Adds a value to a header field of a mutable instance of `URLRequest`.
  ///
  /// This method provides the ability to add values to header fields
  /// incrementally. If a `value` was previously set for the specified `field`,
  /// the supplied value is appended to the existing value using the
  /// appropriate field delimiter (a comma).
  ///
  /// - Parameters:
  ///   - value: The value for the header field.
  ///   - field: The name of the header field. In keeping with the HTTP RFC,
  ///     _HTTP header field names are case-insensitive_.
  @inlinable
  public mutating func append(
    _ value: String,
    for field: String
  ) -> () {
    addValue(value, forHTTPHeaderField: field)
  }

  /// Returns a new instance of `URLRequest` with the given value added to its
  /// header field.
  ///
  /// This method provides the ability to add values to header fields
  /// incrementally. If a `value` was previously set for the specified
  /// `field`, the supplied value is appended to the existing value using
  /// the appropriate field delimiter (a comma).
  ///
  /// - Parameters:
  ///   - value: The value for the header field.
  ///   - field: The name of the header field. In keeping with the HTTP RFC,
  ///     _HTTP header field names are case-insensitive_.
  /// - Returns: a new instance of `URLRequest` with the updated header field.
  @inlinable
  public func appending(
    _ value: String,
    for field: String
  ) -> URLRequest {
    mutating(self, with: URLRequest.append(value, for: field))
  }

  @inlinable
  public mutating func append(_ data: Data) -> () {
    httpBody = data
  }

  @inlinable
  public func appending(_ data: Data) -> URLRequest {
    mutating(self) { $0.httpBody = data }
  }
}

extension URLResponse {

  /// Returns the response's HTTP status code if this is an instance of
  /// `HTTPURLResponse`,  Otherwise, returns `nil`.
  @inlinable
  public var statusCode: Int? {
    (self as? HTTPURLResponse)?.statusCode
  }

  /// Returns a localized string corresponding to this response's status code
  /// if this is an instance of `HTTPURLResponse`,  Otherwise, returns `nil`.
  @inlinable
  public var localizedStatus: String? {
    statusCode.map(HTTPURLResponse.localizedString)
  }
}

// MARK: -
// MARK: - Pointfree thunks

extension URL {

  /// Returns a URL constructed by removing the last path component of a url.
  ///
  /// This function may either remove a path component or append `/..`.
  ///
  /// If the URL has an empty path (e.g., `http://www.example.com`), then
  /// this function will return the URL unchanged.
  @inlinable
  public static func deletingLastPathComponent(_ url: URL) -> URL {
    return url.deletingLastPathComponent()
  }

  /// Returns a URL constructed by removing any path extension.
  ///
  /// If the URL has an empty path (e.g., `http://www.example.com`), then
  /// this function will return the URL unchanged.
  @inlinable
  public static func deletingPathExtension(_ url: URL) -> URL {
    return url.deletingPathExtension()
  }
}

extension URLSessionTask {

  @inlinable
  public static func resume(_ task: URLSessionTask) -> () {
    return task.resume()
  }

  @inlinable
  public static func suspend(_ task: URLSessionTask) -> () {
    return task.suspend()
  }

  @inlinable
  public static func cancel(_ task: URLSessionTask) -> () {
    return task.cancel()
  }
}

extension URLRequest {

  /// Adds a value to a header field of a mutable instance of `URLRequest`.
  ///
  /// This method provides the ability to add values to header fields
  /// incrementally. If a `value` was previously set for the specified
  /// `field`, the supplied value is appended to the existing value using
  /// the appropriate field delimiter (a comma).
  ///
  /// - Parameters:
  ///   - value: The value for the header field.
  ///   - field: The name of the header field. In keeping with the HTTP RFC,
  ///     _HTTP header field names are case-insensitive_.
  /// - Returns: A function taking the mutable instance of `URLRequest` to
  ///   mutate.
  @inlinable
  public static func append(
    _ value: String,
    for field: String
  ) -> (inout URLRequest) -> () {
    return { $0.addValue(value, forHTTPHeaderField: field) }
  }

  /// Returns a new instance of `URLRequest` with the given value added to its
  /// header field.
  ///
  /// This method provides the ability to add values to header fields
  /// incrementally. If a `value` was previously set for the specified
  /// `field`, the supplied value is appended to the existing value using
  /// the appropriate field delimiter (a comma).
  ///
  /// - Parameters:
  ///   - value: The value for the header field.
  ///   - field: The name of the header field. In keeping with the HTTP RFC,
  ///     _HTTP header field names are case-insensitive_.
  /// - Returns: a new instance of `URLRequest` with the updated header field.
  @inlinable
  public static func appending(
    _ value: String,
    for field: String
  ) -> (URLRequest) -> URLRequest {
    return { $0.appending(value, for: field) }
  }

  @inlinable
  public static func append(
    _ data: Data
  ) -> (inout URLRequest) -> () {
    return { $0.append(data) }
  }

  @inlinable
  public static func appending(
    _ data: Data
  ) -> (URLRequest) -> URLRequest {
    return { $0.appending(data) }
  }
}

extension URLResponse {

  /// Returns a localized string corresponding to a given status code.
  @inlinable
  public static func localizedStatus(for statusCode: Int) -> String {
    return HTTPURLResponse.localizedString(forStatusCode: statusCode)
  }
}

// MARK: -
// MARK: - Constants

/// HTTP defines a set of request methods to indicate the desired action to
/// be performed for a given resource. Although they can also be nouns, these
/// request methods are sometimes referred as HTTP verbs. Each of them
/// implements a different semantic, but some common features are shared by
/// a group of them: e.g. a request method can be safe, idempotent, or
/// cacheable.
///
/// - GET: The `GET` method requests a representation of the specified
///   resource. Requests using `GET` should only retrieve data.
/// - HEAD: The `HEAD` method asks for a response identical to that of a GET
///   request, but without the response body.
/// - POST: The `POST` method is used to submit an entity to the specified
///   resource, often causing a change in state or side effects on the server.
/// - PUT: The `PUT` method replaces all current representations of the
///   target resource with the request payload.
/// - DELETE: The `DELETE` method deletes the specified resource.
/// - CONNECT: The `CONNECT` method establishes a tunnel to the server
///   identified by the target resource.
/// - OPTIONS: The `OPTIONS` method is used to describe the communication
///   options for the target resource.
/// - TRACE: The `TRACE` method performs a message loop-back test along the
///   path to the target resource.
/// - PATCH: The `PATCH` method is used to apply partial modifications to a
///   resource.
public enum HTTPMethod: String {
  case
  GET,
  HEAD,
  POST,
  PUT,
  DELETE,
  CONNECT,
  OPTIONS,
  TRACE,
  PATCH
}

extension URL {

  enum Port: Int {
    case
      qotd   = 17,
      ftp    = 20,
      ssh    = 22,
      telnet = 23,
      smtp   = 25,
      dns    = 53,
      web    = 80,
      pop3   = 110,
      nntp   = 119,
      ntp    = 123,
      imap   = 143,
      snmp   = 161,
      irc    = 194,
      ssl    = 443
  }
}

extension URL {

  enum Scheme: String {
    case
      about,
      data,
      file,
      ftp,
      http,
      https,
      ldap,
      mailto,
      news,
      nntp,
      tel,
      telnet,
      urn,

      // apple
      appprefs = "App-prefs",
      applefeedback,
      applenews,
      applenewss,
      audioplayerevent = "audio-player-event",
      calshow,
      clips,
      contacts,
      diagnostics,
      diags,
      facetime,
      facetimeaudio = "facetime-audio",
      facetimeaudioprompt = "facetime-audio-prompt",
      facetimeprompt = "facetime-prompt",
      fmip1,
      gamecenter,
      ibooks,
      itms,
      itmsapps = "itms-apps",
      itmsbooks = "itms-books",
      itmsbookss = "itms-bookss",
      itmsgc = "itms-gc",
      itmsgcs = "itms-gcs",
      itmss,
      map,
      mapitem,
      maps,
      message,
      mobilenotes,
      music,
      musics,
      photosredirect = "photos-redirect",
      remote,
      shoebox,
      sms,
      telprompt,
      videos,
      voicememos,
      workflow,
      xapplecalevent = "x-apple-calevent",
      xapplereminder = "x-apple-reminder",
      xwebsearch = "x-web-search"
  }
}

public enum HTTPField: String {
  case
    // General
    cacheControl = "Cache-Control",
    connection = "Connection",
    contentLength = "Content-Length",
    contentMD5 = "Content-MD5",
    contentType = "Content-Type",
    date = "Date",
    sessionId = "Session-Id",
    via = "Via",

    // Request
    accept = "Accept",
    acceptCharset = "Accept-Charset",
    acceptEncoding = "Accept-Encoding",
    acceptLanguage = "Accept-Language",
    acceptDatetime = "Accept-Datetime",
    authorization = "Authorization",
    cookie = "Cookie",
    expect = "Expect",
    forwarded = "Forwarded",
    from = "From",
    host = "Host",
    http2Settings = "HTTP2-Settings",
    ifMatch = "If-Match",
    ifModifiedSince = "If-Modified-Since",
    ifNoneMatch = "If-None-Match",
    ifRange = "If-Range",
    ifUnmodifiedSince = "If-Unmodified-Since",
    maxForwards = "Max-Forwards",
    pragma = "Pragma",
    proxyAuthorization = "Proxy-Authorization",
    range = "Range",
    referer = "Referer",
    te = "TE",
    userAgent = "User-Agent",
    upgrade = "Upgrade",
    warning = "Warning",

    // Response
    acceptPatch = "Accept-Patch",
    acceptRanges = "Accept-Ranges",
    age = "Age",
    allow = "Allow",
    altSvc = "Alt-Svc",
    contentDisposition = "Content-Disposition",
    contentEncoding = "Content-Encoding",
    contentLanguage = "Content-Language",
    contentLocation = "Content-Location",
    contentRange = "Content-Range",
    deltaBase = "Delta-Base",
    etag = "ETag",
    expires = "Expires",
    im = "IM",
    last = "Last",
    link = "Link",
    location = "Location",
    p3p = "P3P",
    proxyAuthenticate = "Proxy-Authenticate",
    publicKeyPins = "Public-Key-Pins",
    retryAfter = "Retry-After",
    server = "Server",
    setCookie = "Set-Cookie",
    strictTransportSecurity = "Strict-Transport-Security",
    trailer = "Trailer",
    transferEncoding = "Transfer-Encoding",
    wwwAuthenticate = "WWW-Authenticate",
    xFrameOptions = "X-Frame-Options"
}

public enum MIME: String {
  case // MIME
    js = "application/javascript",
    json = "application/json",
    xml = "application/xml",
    zip = "application/zip",
    pdf = "application/pdf",
    sql = "application/sql",
    graphql = "application/graphql",
    ldjson = "application/ld+json",
    mpeg = "audio/mpeg",
    ogg = "audio/ogg",
    form = "multipart/form-data",
    css = "text/css",
    html = "text/html",
    csv = "text/csv",
    plain = "text/plain",
    png = "image/png",
    jpeg = "image/jpeg",
    gif  = "image/gif"
}

public enum HTTPInformationCode: Int {
  case
    `continue` = 100,
    switchingProtocol = 101,
    processing = 102,
    checkpoint = 103 // nonstd
}

public enum HTTPSuccessCode: Int {
  case
    ok = 200,
    created = 201,
    accepted = 202,
    nonAuthoritative = 203,
    noContent = 204,
    resetContent = 205,
    partialContent = 206,
    alreadyReported = 208,
    thisIsFine = 218 // apache
}

public enum HTTPRedirectCode: Int {
  case
    multipleChoice = 300,
    movedPermanently = 301,
    found = 302,
    seeOther = 303,
    notModified = 304,
    useProxy = 305,
    switchProxy = 306,
    temporaryRedirect = 307,
    permanentRedirect = 308
}

/// - Tag: HTTPCodes.ClientError
public enum HTTPError: Int, Swift.Error {
  case
    // Client
    badRequest = 400,
    unauthorized = 401,
    paymentRequired = 402,
    forbidden = 403,
    notFound = 404,
    methodNotAllowed = 405,
    notAcceptable = 406,
    proxyAuthenticationRequired = 407,
    requestTimeout = 408,
    conflict = 409,
    gone = 410,
    lengthRequired = 411,
    preconditionFailed = 412,
    payloadTooLarge = 413,
    uriTooLong = 414,
    unsupportedMediaType = 415,
    requestedRangeNotSatisfiable = 416,
    expectationFailed = 417,
    imATeapot = 418,
    pageExpired = 419, // laravel
    enhanceYourCalm = 420, // twitter
    tooEarly = 425,
    upgradeRequired = 426,
    preconditionRequired = 428,
    tooManyRequests = 429,
    requestHeaderFieldsTooLarge = 431,
    unavailableForLegalReasons = 451,
    requestHeaderTooLarge = 494, // nonstd
    sslCertificateError = 495, // nginx
    sslCertificateRequired = 496, // nginx
    httpRequestSentToHTTPSPort = 497, // nginx
    invalidToken = 498, // esri
    clientClosedRequest = 490, // nginx

  // Server
    internalServerError = 500,
    notImplemented = 501,
    badGateway = 502,
    serviceUnavailable = 503,
    gatewayTimeout = 504,
    httpVersionNotSupported = 505,
    variantAlsoNegotiates = 506,
    insufficientStorage = 507,
    loopDetected = 508,
    bandwidthLimitExceeded = 509, // apache
    notExtended = 510,
    networkAuthenticationRequired = 511,
    unknownError = 520, // nonstd
    networkReadTimeout = 598 // nonstd
}

// MARK: -

extension DefaultStringInterpolation {

  mutating func appendInterpolation(_ value: URL.Port) {
    appendInterpolation(value.rawValue)
  }

  mutating func appendInterpolation(_ value: URL.Scheme) {
    appendInterpolation(value.rawValue)
  }

  mutating func appendInterpolation(_ value: HTTPMethod) {
    appendInterpolation(value.rawValue)
  }

  mutating func appendInterpolation(_ value: HTTPField) {
    appendInterpolation(value.rawValue)
  }

  mutating func appendInterpolation(_ value: MIME) {
    appendInterpolation(value.rawValue)
  }

  mutating func appendInterpolation(_ value: HTTPInformationCode) {
    appendInterpolation(value.rawValue)
  }

  mutating func appendInterpolation(_ value: HTTPSuccessCode) {
    appendInterpolation(value.rawValue)
  }

  mutating func appendInterpolation(_ value: HTTPRedirectCode) {
    appendInterpolation(value.rawValue)
  }

  mutating func appendInterpolation(_ value: HTTPError) {
    appendInterpolation(value.rawValue)
  }
}
