
import Foundation

extension NSDate {
    static func from(string: String) -> NSDate? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        
        return df.date(from: string) as NSDate?
    }
}
