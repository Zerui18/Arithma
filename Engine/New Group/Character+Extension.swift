import Foundation
import Darwin

extension Character {
    public var value: Int32 {
        return Int32(unicodeScalars.first!.value)
    }
    public var isSpace: Bool {
        return isspace(value) != 0
    }
    public var isAlpha: Bool {
        return isalpha(value) != 0
    }
    public var isNumber: Bool {
        return isnumber(value) != 0
    }
    
    
    public var isAlphanumeric: Bool {
        return isAlpha || isNumber
    }
}
