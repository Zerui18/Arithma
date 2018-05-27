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
    public func description(sf: Int32)-> String {
        var imcopy = im
        let connector = (imcopy.sign() == .plus && !re.isZero && !im.isZero) ? "+":""
        let real = re.isZero && !im.isZero ? "":re.description(sf: sf)
        let imaginary = im.isZero ? "":"\(im.description(sf: sf))i"
        return real + connector + imaginary
    }
    
    public var description: String {
        return description(sf: 100000)
    }
    
    public var debugDescription: String {
        return description
    }
    
    public var isZero: Bool {
        return cxeq(self, .zero) != 0
    }
    
    public var isReal: Bool {
        return xeq(im, xZero) != 0
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
    
    public var lg: HPAComplex {
        return cxlog10(self)
    }
    
    public var ln: HPAComplex {
        return cxlog(self)
    }
    
    public var exp: HPAComplex {
        return cxexp(self)
    }
    
    public var abs: HPAReal {
        return cxabs(self)
    }
    
    public var sqrt: HPAComplex {
        return cxsqrt(self)
    }
    
    public var floor: HPAComplex {
        return cxfloor(self)
    }
    
    public func pow(e: HPAComplex)-> HPAComplex {
        // short-cut if e is real & e is integer
        ShortCut:
        if e.isReal && xfloor(e.re) == e.re {
            let double = xtodbl(e.re)
            if double > Double(Int32.max) {
                break ShortCut
            }
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
