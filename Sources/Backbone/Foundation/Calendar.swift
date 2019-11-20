import struct Foundation.TimeZone
import struct Foundation.Date
import class Foundation.DateFormatter

extension TimeZone {

  // based off TimeZone.abbreviationsDictionary

  public static let AKDT = TimeZone(abbreviation: "AKDT")
  public static let WEST = TimeZone(abbreviation: "WEST")
  public static let AST = TimeZone(abbreviation: "AST")
  public static let MDT = TimeZone(abbreviation: "MDT")
  public static let COT = TimeZone(abbreviation: "COT")
  public static let NZDT = TimeZone(abbreviation: "NZDT")
  public static let BRST = TimeZone(abbreviation: "BRST")
  public static let EDT = TimeZone(abbreviation: "EDT")
  public static let EEST = TimeZone(abbreviation: "EEST")
  public static let IRST = TimeZone(abbreviation: "IRST")
  public static let HKT = TimeZone(abbreviation: "HKT")
  public static let PDT = TimeZone(abbreviation: "PDT")
  public static let MSK = TimeZone(abbreviation: "MSK")
  public static let UTC = TimeZone(abbreviation: "UTC")
  public static let EAT = TimeZone(abbreviation: "EAT")
  public static let NDT = TimeZone(abbreviation: "NDT")
  public static let MST = TimeZone(abbreviation: "MST")
  public static let WET = TimeZone(abbreviation: "WET")
  public static let CEST = TimeZone(abbreviation: "CEST")
  public static let PST = TimeZone(abbreviation: "PST")
  public static let HST = TimeZone(abbreviation: "HST")
  public static let KST = TimeZone(abbreviation: "KST")
  public static let EET = TimeZone(abbreviation: "EET")
  public static let BRT = TimeZone(abbreviation: "BRT")
  public static let CLST = TimeZone(abbreviation: "CLST")
  public static let PET = TimeZone(abbreviation: "PET")
  public static let AKST = TimeZone(abbreviation: "AKST")
  public static let CST = TimeZone(abbreviation: "CST")
  public static let WIT = TimeZone(abbreviation: "WIT")
  public static let NST = TimeZone(abbreviation: "NST")
  public static let ICT = TimeZone(abbreviation: "ICT")
  public static let GMT = TimeZone(abbreviation: "GMT")
  public static let PHT = TimeZone(abbreviation: "PHT")
  public static let CLT = TimeZone(abbreviation: "CLT")
  public static let WAT = TimeZone(abbreviation: "WAT")
  public static let MSD = TimeZone(abbreviation: "MSD")
  public static let TRT = TimeZone(abbreviation: "TRT")
  public static let CDT = TimeZone(abbreviation: "CDT")
  public static let NZST = TimeZone(abbreviation: "NZST")
  public static let CAT = TimeZone(abbreviation: "CAT")
  public static let SGT = TimeZone(abbreviation: "SGT")
  public static let ADT = TimeZone(abbreviation: "ADT")
  public static let PKT = TimeZone(abbreviation: "PKT")
  public static let JST = TimeZone(abbreviation: "JST")
  public static let IST = TimeZone(abbreviation: "IST")
  public static let BST = TimeZone(abbreviation: "BST")
  public static let BDT = TimeZone(abbreviation: "BDT")
  public static let EST = TimeZone(abbreviation: "EST")
  public static let GST = TimeZone(abbreviation: "GST")
  public static let CET = TimeZone(abbreviation: "CET")
  public static let ART = TimeZone(abbreviation: "ART")
}

extension Date {

  @inlinable
  public init?(_ string: String, formatter: DateFormatter) {
    guard let date = formatter.date(from: string) else { return nil }
    self = date
  }
}

extension String {

  @inlinable
  public init(_ date: Date, formatter: DateFormatter) {
    self = formatter.string(from: date)
  }
}
