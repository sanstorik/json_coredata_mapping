
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


func isStorageType(value: Any) -> Bool {
    return value is [String: Any]
        || value is [[String: Any]]
        || value is [String]
}


func cocoaTypeFor(value: (String, Any)) -> String {
    return dataTypeFor(value: value, string: "string", date: "date",
                       int64: "int64", float: "float", bool: "bool")
}


func coreDataTypeFor(value: (String, Any)) -> String {
    return dataTypeFor(value: value, string: "String", date: "Date",
                       int64: "Integer 64", float: "Float", bool: "Boolean")
}


private func dataTypeFor(value: (String, Any),
                         string: String,
                         date: String,
                         int64: String,
                         float: String,
                         bool: String) -> String {
    if value.0.starts(with: "is") { return bool }
    
    var type = string
    if value.1 is String {
        if NSDate.from(string: value.1 as! String) != nil {
            type = date
        } else if isBoolean(value) { type = bool }
    } else if value.1 is Int64 || value.1 is Int {
        type = int64
    } else if value.1 is Float || value.1 is Double {
        type = float
    } else if value.1 is Bool {
        type = bool
    }
    
    return type
}


private func isBoolean(_ value: Any) -> Bool {
    return value is Bool
        ||  (value is String
            && ((value as! String).caseInsensitiveCompare("true") == .orderedSame
                || (value as! String).caseInsensitiveCompare("false") == .orderedSame))
}
