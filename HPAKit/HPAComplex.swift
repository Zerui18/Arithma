//
//  Complex.swift
//  HPAKit
//
//  Created by Chen Zerui on 25/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import HPA

public typealias HPAComplex = cxpr

extension HPAComplex: HPANumeric {
    
    // MARK: Expressibles Conformances
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    
    public init(integerLiteral value: Int) {
        self = cxpr(re: inttox(value), im: .zero)
    }
    
    public init(floatLiteral value: Double) {
        self = cxpr(re: dbltox(value), im: .zero)
    }
    
    // MARK: Static Variables
    public static let zero = cxZero
    public static let i = cxIU
    
    // MARK: Description
    @inline(__always)
    public func description(sf: Int32)-> String {
        return String(cString: cxpr_asprint(self, 0, 0, sf))
    }
    
    public var isZero: Bool {
        return cxeq(self, .zero) != 0
    }
    
    // MARK: Math Functions
    public var sin: HPAComplex {
        return cxsin(self)
    }
    
    public var cos: HPAComplex {
        return cxcos(self)
    }
    
    public var tan: HPAComplex {
        return cxtan(self)
    }
    
    public var asin: HPAComplex {
        return cxasin(self)
    }
    
    public var acos: HPAComplex {
        return cxacos(self)
    }
    
    public var atan: HPAComplex {
        return cxatan(self)
    }
    
    public var abs: HPAReal {
        return cxabs(self)
    }
    
    public var sqrt: cxpr {
        return cxsqrt(self)
    }
    
    public var isReal: Bool {
        return xeq(im, xZero) != 0
    }
    
    @inline(__always)
    public func pow(e: HPAComplex)-> HPAComplex {
        // short-cut if e is real & e is integer
        if e.isReal && xfloor(e.re) == e.re {
            return cxpwr(self, Int32(xtodbl(e.re)))
        }
        return cxpow(self, e)
    }
    
}

// MARK: Operator Overloads

@inline(__always)
public func == (lhs: cxpr, rhs: cxpr) -> Bool {
    return cxeq(lhs, rhs) != 0
}

@inline(__always)
public func +(lhs: HPAComplex, rhs: HPAComplex)-> HPAComplex {
    return cxadd(lhs, rhs, 0)
}

@inline(__always)
public func -(lhs: HPAComplex, rhs: HPAComplex)-> HPAComplex {
    return cxsub(lhs, rhs)
}

@inline(__always)
public prefix func -(rhs: HPAComplex)-> HPAComplex {
    return cxneg(rhs)
}

@inline(__always)
public func *(lhs: HPAComplex, rhs: HPAComplex)-> HPAComplex {
    return cxmul(lhs, rhs)
}

@inline(__always)
public func /(lhs: HPAComplex, rhs: HPAComplex)-> HPAComplex {
    return cxdiv(lhs, rhs)
}
