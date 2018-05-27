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
    public static let epsilon: HPAReal = 1e-30
    
    // MARK: Description
    @inline(__always)
    public func description(sf: Int32)-> String {
        return String(cString:
            xpr_asprint(self, SSettings.shared.isScientificMode ? 1:0, 0, sf)
        )
    }
    
    public var description: String {
        return description(sf: 100000)
    }
    
    public var debugDescription: String {
        return description
    }
    
    public var isZero: Bool {
        return xeq(self, .zero) != 0
    }
    
    public mutating func sign()-> FloatingPointSign {
        return xsgn(&self) != -1 ? .plus:.minus
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
