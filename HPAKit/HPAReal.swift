//
//  Real.swift
//  HPAKit
//
//  Created by Chen Zerui on 25/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import HPA
import Settings

public typealias HPAReal = xpr

extension HPAReal: HPANumeric, Comparable{
    
    // MARK: Expressibles Conformances
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    
    public init(integerLiteral value: Int) {
        self = inttox(value)
    }
    
    public init(floatLiteral value: Double) {
        self = dbltox(value)
    }
    
    public init?(_ string: String) {
        var value = string.cString(using: .ascii)!.withUnsafeBufferPointer {
            strtox($0.baseAddress!, nil)
        }
        if xisNaN(&value) != 0 {
            return nil
        }
        else {
            self = value
        }
    }
    
    // MARK: Static Variables
    public static let zero = xZero
    public static let epsilon: HPAReal = 1e-100
    
    // MARK: Description
    public func description(sf: Int32)-> String {
        var str = String(cString:
            xpr_asprint(self, AMSettings.shared.isScientificMode ? 1:0, 0, sf)
        )
        
        if str.contains("e") || str.contains(".") {
            var index: String.Index
            if str.contains("e") {
                // fallback to older swift
                index = str.firstIndex(of: "e")!
//                index = str.firstIndex(of: "e")!
            }
            else {
                index = str.endIndex
            }
            
            index = str.index(before: index)
            
            while index >= str.startIndex, str[index] == "0" {
                str.remove(at: index)
                index = str.index(before: index)
            }
            if str[index] == "." {
                str.remove(at: index)
            }
        }
        return str
    }
    
    public var description: String {
        return description(sf: 100000)
    }
    
    public var debugDescription: String {
        return description
    }
    
    public var isZero: Bool {
        return abs < .epsilon
    }
    
    @inline(__always)
    public func sign()-> FloatingPointSign {
        var copy = self
        return xsgn(&copy) != -1 ? .plus:.minus
    }
    
    // MARK: Math Functions
    public var sin: HPAReal {
        return xsin(self)
    }
    
    public var cos: HPAReal {
        return xcos(self)
    }
    
    public var tan: HPAReal {
        return xtan(self)
    }
    
    public var asin: HPAReal {
        return xasin(self)
    }
    
    public var acos: HPAReal {
        return xacos(self)
    }
    
    public var atan: HPAReal {
        return xatan(self)
    }
    
    public var sinh: HPAReal {
        return xsinh(self)
    }
    
    public var cosh: HPAReal {
        return xcosh(self)
    }
    
    public var tanh: HPAReal {
        return xtanh(self)
    }
    
    public var asinh: HPAReal {
        return xasinh(self)
    }
    
    public var acosh: HPAReal {
        return xacosh(self)
    }
    
    public var atanh: HPAReal {
        return xatanh(self)
    }
    
    public var lg: HPAReal {
        return xlog10(self)
    }
    
    public var ln: HPAReal {
        return xlog(self)
    }
    
    public var exp: HPAReal {
        return xexp(self)
    }
    
    public var abs: HPAReal {
        return xabs(self)
    }
    
    public var sqrt: HPAReal {
        return xsqrt(self)
    }
    
    public var floor: HPAReal {
        return xfloor(self)
    }
    
    @inline(__always)
    public func pow(e: HPAReal)-> HPAReal {
        // short-cut if e is integer
        if xfloor(e) == e {
            return xpwr(self, Int32(xtodbl(e)))
        }
        return xpow(self, e)
    }
    
    public static let e = xEe
    public static let pi = xPi
}

// MARK: Codable
extension HPAReal {
    
    enum CodingKeys: CodingKey {
        case data
    }
    
    var data: [UInt16] {
        get {
            var copy = nmm
            return withUnsafeBytes(of: &copy) { (tuplePointer) in
                let elementPointer = tuplePointer.baseAddress!.assumingMemoryBound(to: UInt16.self)
                return Array(UnsafeBufferPointer(start: elementPointer, count: Int(XDIM+1)))
            }
        }
        set {
            withUnsafeMutableBytes(of: &nmm) { (tuplePointer) in
                let elementPointer = tuplePointer.baseAddress!.assumingMemoryBound(to: UInt16.self)
                elementPointer.assign(from: newValue, count: Int(XDIM+1))
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        self.data = try container.decode([UInt16].self, forKey: .data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }
}

// MARK: Operator Overloads
@inline(__always)
public func == (lhs: xpr, rhs: xpr) -> Bool {
    return xeq(lhs, rhs) != 0
}

@inline(__always)
public func < (lhs: xpr, rhs: xpr) -> Bool {
    return xlt(lhs, rhs) != 0
}

@inline(__always)
public func +(lhs: HPAReal, rhs: HPAReal)-> HPAReal {
    return xadd(lhs, rhs, 0)
}

@inline(__always)
public func -(lhs: HPAReal, rhs: HPAReal)-> HPAReal {
    return xadd(lhs, rhs, 1)
}

@inline(__always)
public prefix func -(rhs: HPAReal)-> HPAReal {
    return xneg(rhs)
}

@inline(__always)
public func *(lhs: HPAReal, rhs: HPAReal)-> HPAReal {
    return xmul(lhs, rhs)
}

@inline(__always)
public func /(lhs: HPAReal, rhs: HPAReal)-> HPAReal {
    return xdiv(lhs, rhs)
}
