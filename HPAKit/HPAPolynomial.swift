//
//  HPAPolynomial.swift
//  HPAKit
//
//  Created by Chen Zerui on 26/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation

public struct HPAPolynomial: Equatable {
    
    public let coefficients: [HPAReal]
    
    /**
     Creates a new instance of `Polynomial` with the given coefficients.
     
     :param: coefficients The coefficients for the terms of the polinomial, ordered from the coefficient for the highest-degree term to the coefficient for the 0 degree term.
     */
    public init(_ coefficients: HPAReal...) {
        self.init(coefficients)
    }
    
    /**
     Creates a new instance of `Polynomial` with the given coefficients.
     
     :param: coefficients The coefficients for the terms of the polinomial, ordered from the coefficient for the highest-degree term to the coefficient for the 0 degree term.
     */
    public init(_ coefficients: [HPAReal]) {
        if coefficients.count == 0 || (coefficients.count == 1 && coefficients[0].isZero) {
            preconditionFailure("the zero polynomial is undefined")
        }
        self.coefficients = coefficients
    }
    
    /// The grade of the polinomial. It's equal to the number of coefficient minus one.
    public var degree: Int {
        return coefficients.count - 1
    }
    
    /// Finds the roots of the polinomial.
    public func roots(preferClosedFormSolution: Bool = true) -> [HPAComplex] {
        if (preferClosedFormSolution && degree <= 4) {
            switch degree {
            case 0:
                return [] // Empty set (i.e. no solutions to `k = 0`, when k != 0)
            case 1:
                return linear()
            case 2:
                return quadratic()
            case 3:
                return cubic()
            case 4:
                return quartic()
            default:
                fatalError("Not reachable")
            }
        } else {
            return durandKernerMethod()
        }
    }
    
    // MARK: Private methods
    
    private func linear() -> [HPAComplex] {
        let a = coefficients[0]
        let b = coefficients[1]
        
        if a.isZero {
            return []
        }
        
        let x = -b/a
        return [HPAComplex(re: x, im: 0.0)]
    }
    
    private func quadratic() -> [HPAComplex] {
        let a = coefficients[0]
        let b = coefficients[1]
        let c = coefficients[2]
        
        if a.isZero {
            return HPAPolynomial(b, c).roots()
        }
        
        if c.isZero {
            return [HPAComplex.zero] + HPAPolynomial(a, b).roots()
        }
        
        let discriminant = (b * b) - (4.0 * a * c)
        var dSqrt = HPAComplex(re: discriminant, im: 0.0).sqrt
        if b.sign() == .minus {
            dSqrt = -dSqrt
        }
        let x1 = -(HPAComplex(re: b, im: .zero) + dSqrt) / HPAComplex(re: 2.0 * a, im: .zero)
        let x2 = c.toComplex / (a.toComplex * x1)
        
        return [x1, x2]
    }
    
    private func cubic() -> [HPAComplex] {
        let a = coefficients[0]
        var b = coefficients[1]
        var c = coefficients[2]
        var d = coefficients[3]
        
        if a.isZero {
            return HPAPolynomial(b, c, d).roots()
        }
        if d.isZero {
            return [HPAComplex.zero] + HPAPolynomial(a, b, c).roots()
        }
        if a != 1 {
            b = b / a
            c = c / a
            d = d / a
        }
        
        let b2 = b*b
        let b3 = b2*b
        
        let D0 = b2 - (3.0 * c)
        let bc9 = 9.0 * b * c
        let D1 = (2.0 * b3) - bc9 + (27.0 * d)
        let D12 = D1 * D1
        let D03 = D0 * D0 * D0
        let minus27D = D12 - (4.0 * D03)
        var squareRoot = HPAComplex(re: minus27D, im: 0.0).sqrt
        let oneThird: HPAReal = 1.0/3.0
        let zero: HPAReal = 0.0
        
        switch (D0.isZero, minus27D.isZero) {
        case (true, true):
            let x = HPAComplex(re: -oneThird * b, im: zero)
            return [x, x, x]
        case (false, true):
            let d9 = 9.0 * d
            let bc4 = 4.0 * b * c
            let x12 = HPAComplex(re: (d9 - b * c) / (2.0 * D0), im: zero)
            let x3 = HPAComplex(re: (bc4 - d9 - b3) / D0, im: zero)
            return [x12, x12, x3]
        case (true, false):
            if (D1.toComplex + squareRoot) == .zero {
                squareRoot = -squareRoot
            }
            fallthrough
        default:
            let C = (0.5 * (D1.toComplex + squareRoot)).pow(e: HPAComplex(re: oneThird, im: 0))
            
            let im = HPAComplex(re: 0.0, im: HPAReal(floatLiteral: 0.5*sqrt(3.0)))
            let u2 = -0.5 + im
            let u3 = -0.5 - im
            let u2C = u2 * C
            let u3C = u3 * C
            
            let bC = b.toComplex
            let D0C = D0.toComplex
            
            let x13 = bC + C + (D0C / C)
            let x23 = bC + u2C + (D0C / u2C)
            let x33 = bC + u3C + (D0C / u3C)
            
            let negOneThirdC = (-oneThird).toComplex
            
            let x1 = negOneThirdC * x13
            let x2 = negOneThirdC * x23
            let x3 = negOneThirdC * x33
            
            return [x1, x2, x3]
        }
    }
    
    private func quartic() -> [HPAComplex] {
        var a = coefficients[0]
        var b = coefficients[1]
        var c = coefficients[2]
        var d = coefficients[3]
        let e = coefficients[4]
        
        if a.isZero {
            return HPAPolynomial(b, c, d, e).roots()
        }
        if e.isZero {
            return [HPAComplex.zero] + HPAPolynomial(a, b, c, d).roots()
        }
        if b.isZero && d.isZero { // Biquadratic
            let squares = HPAPolynomial(a, c, e).roots()
            return squares.flatMap { (square: HPAComplex) -> [HPAComplex] in
                let x = square.sqrt
                return [x, -x]
            }
        }
        
        // Lodovico Ferrari's solution
        
        // Converting to a depressed quartic
        let a1 = b/a
        b = c/a
        c = d/a
        d = e/a
        a = a1
        
        let a2 = a*a
        let minus3a2 = -3.0*a2
        let ac64 = 64.0*a*c
        let a2b16 = 16.0*a2*b
        let aOn4 = a/4.0
        
        let p = b + minus3a2/8.0
        let ab4 = 4.0*a*b
        let q = (a2*a - ab4)/8.0 + c
        let r1 = minus3a2*a2 - ac64 + a2b16
        let r = r1/256.0 + d
        
        // Depressed quartic: u^4 + p*u^2 + q*u + r = 0
        
        if q.isZero { // Depressed quartic is biquadratic
            let squares = HPAPolynomial(1.0, p, r).roots()
            return squares.flatMap { (square: HPAComplex) -> [HPAComplex] in
                let x = square.sqrt
                return [x - aOn4.toComplex, -x - aOn4.toComplex]
            }
        }
        
        let p2 = p*p
        let q2On8 = q*q/8.0
        
        let cb = 2.5*p
        let cc = 2.0*p2 - r
        let cd = 0.5*p*(p2-r) - q2On8
        let yRoots = HPAPolynomial(1.0, cb, cc, cd).roots()
        
        let y = yRoots[yRoots.startIndex]
        let y2 = 2.0*y
        let sqrtPPlus2y = (p.toComplex + y2).sqrt
        precondition(sqrtPPlus2y.isZero == false, "Failed to properly handle the case of the depressed quartic being biquadratic")
        let p3 = 3.0*p
        let q2 = 2.0*q
        let fraction = q2.toComplex/sqrtPPlus2y
        let p3Plus2y = p3.toComplex + y2
        let u1 = 0.5*(sqrtPPlus2y + (-(p3Plus2y + fraction)).sqrt)
        let u2 = 0.5*(-sqrtPPlus2y + (-(p3Plus2y - fraction)).sqrt)
        let u3 = 0.5*(sqrtPPlus2y - (-(p3Plus2y + fraction)).sqrt)
        let u4 = 0.5*(-sqrtPPlus2y - (-(p3Plus2y - fraction)).sqrt)
        let aOn4C = aOn4.toComplex
        return [
            u1 - aOn4C,
            u2 - aOn4C,
            u3 - aOn4C,
            u4 - aOn4C
        ]
    }
    
    /// Implementation of the [Durand-Kerner-Weierstrass method](https://en.wikipedia.org/wiki/Durand%E2%80%93Kerner_method).
    private func durandKernerMethod() -> [HPAComplex] {
        var coefficients = self.coefficients.map { $0.toComplex }
        
        let one = HPAReal(integerLiteral: 1).toComplex
        
        if coefficients[0] != one {
            coefficients = coefficients.map { coefficient in
                coefficient / coefficients[0]
            }
        }
        
        var a0 = [one]
        for _ in 1..<coefficients.count-1 {
            a0.append(a0.last! * HPAComplex(re: 0.4, im: 0.9))
        }
        
        var count = 0
        while count < 1000 {
            var roots: [HPAComplex] = []
            var i = 0
            while i < a0.count {
                var result = one
                var j = 0
                while j < a0.count {
                    if i != j {
                        result = (a0[i] - a0[j]) * result
                    }
                    
                    j += 1
                }
                roots.append(a0[i] - (eval(coefficients, a0[i]) / result))
                i += 1
            }
            if done(a0, roots) {
                return roots
            }
            a0 = roots
            count += 1
        }
        
        return a0
    }
    
    private func eval(_ coefficients: [HPAComplex], _ x: HPAComplex) -> HPAComplex {
        var result = coefficients[0]
        for i in 1..<coefficients.count {
            result = (result * x) + coefficients[i]
        }
        return result
    }
    
    private func done(_ aa: [HPAComplex], _ bb: [HPAComplex], _ epsilon: HPAReal = .epsilon) -> Bool {
        for (a, b) in zip(aa, bb) {
            let delta = a - b
            if delta.abs > epsilon {
                return false
            }
        }
        return true
    }
    
}

// MARK: Equatable

public func == (_ lhs: HPAPolynomial, _ rhs: HPAPolynomial) -> Bool {
    return lhs.coefficients == rhs.coefficients
}
