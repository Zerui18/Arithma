//
//  HPANumeric.swift
//  HPAKit
//
//  Created by Chen Zerui on 25/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

public protocol HPANumeric: Equatable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible, CustomDebugStringConvertible, Codable {
    
    func description(sf: Int32)-> String
    
    var isZero: Bool {get}
    
    var sin: Self {get}
    var cos: Self {get}
    var tan: Self {get}
    
    var asin: Self {get}
    var acos: Self {get}
    var atan: Self {get}
    
    var sinh: Self {get}
    var cosh: Self {get}
    var tanh: Self {get}
    
    var asinh: Self {get}
    var acosh: Self {get}
    var atanh: Self {get}
    
    var lg: Self {get}
    var ln: Self {get}
    var exp: Self {get}
    
    var abs: HPAReal {get}
    var sqrt: Self {get}
    var floor: Self {get}
    
    func pow(e: Self)-> Self
    
    static func +(lhs: Self, rhs: Self)-> Self
    static func -(lhs: Self, rhs: Self)-> Self
    static func *(lhs: Self, rhs: Self)-> Self
    static func /(lhs: Self, rhs: Self)-> Self
    
}
