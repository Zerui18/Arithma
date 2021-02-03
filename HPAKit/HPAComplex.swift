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
    
    public init(_ value: Int) {
        self = cxpr(re: inttox(value), im: .zero)
    }
    
    public init(_ value: Double) {
        self = cxpr(re: dbltox(value), im: .zero)
    }
    
    public init(integerLiteral value: Int) {
        self = HPAComplex(value)
    }
    
    public init(floatLiteral value: Double) {
        self = HPAComplex(value)
    }
    
    // MARK: Static Variables
    public static let zero = cxZero
    public static let i = cxIU
    
    // MARK: Description
    public func description(sf: Int32)-> String {
        let connector = (im.sign() == .plus && !re.isZero && !im.isZero) ? "+":""
        let real = re.isZero && !im.isZero ? "":re.description(sf: sf)
        let imaginary = im.isZero ? "":"\(im.description(sf: sf))i"
        return real + connector + imaginary
    }
    
    public var description: String {
        return description(sf: 9)
    }
    
    public var debugDescription: String {
        return description
    }
    
    public var isZero: Bool {
        return im.isZero && re.isZero
    }
    
    public var isReal: Bool {
        return im.isZero
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
    
    public var sinh: HPAComplex {
        return cxsinh(self)
    }
    
    public var cosh: HPAComplex {
        return cxcosh(self)
    }
    
    public var tanh: HPAComplex {
        return cxtanh(self)
    }
    
    public var asinh: HPAComplex {
        return cxasinh(self)
    }
    
    public var acosh: HPAComplex {
        return cxacosh(self)
    }
    
    public var atanh: HPAComplex {
        return cxatanh(self)
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
        // fix to get accurate sqrt of real
        if isReal {
            let val = re.abs.sqrt
            return re.sign() == .minus ? HPAComplex(re: .zero, im: val):val.toComplex
        }
        return cxsqrt(self)
    }
    
    public var floor: HPAComplex {
        return cxfloor(self)
    }
    
    public var ceil: HPAComplex {
        return cxceil(self)
    }
    
    // https://socratic.org/precalculus/complex-numbers-in-trigonometric-form/roots-of-complex-numbers
    public var cbrt: HPAComplex {
        let arg = cxarg(self)
        let abs = cxabs(self)
        let coeff = abs.pow(e: 1/3)
        let real = coeff * (arg/3).cos
        let imag = coeff * (arg/3).sin
        return HPAComplex(re: real, im: imag)
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

// MARK: Codable
extension HPAComplex {
    public enum CodingKeys: CodingKey {
        case re, im
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(re: try container.decode(HPAReal.self, forKey: .re),
                  im: try container.decode(HPAReal.self, forKey: .im))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(re, forKey: .re)
        try container.encode(im, forKey: .im)
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
