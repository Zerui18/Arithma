//
//  SCompoundUnit.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import ExtMathLib
import CComplex

public struct SCompoundUnit: SUnitRepresentable {
    
    // MARK: Internal Properties
    var unitToPower = [SBasicUnit: Int]()
    var baseUnitToPower: [SBasicUnit: Int] {
        var dict = [SBasicUnit: Int]()
        
        for (unit, power) in unitToPower {
            dict[unit.baseUnit, default: 0] += power
            if dict[unit.baseUnit] == 0 {
                dict[unit.baseUnit] = nil
            }
        }
        return dict
    }
    
    public var description: String {
        return baseUnitToPower.reduce("", {$0 + $1.key.description + ($1.value != 1 ? "^\($1.value)":"")})
    }
    
    // MARK: Init
    public init() {}
    
    public init(containingBaseUnit unit: SBasicUnit, ofPower power: Int = 1) {
        unitToPower[unit] = power
    }
    
    public init(dictionaryRepresentation: [SBasicUnit: Int]) {
        unitToPower = dictionaryRepresentation
    }
    
    // MARK: Public Methods
    public func adding<UnitType: SUnitRepresentable>(other unit: UnitType, by factor: Int = 1)-> SCompoundUnit {
        var copy = self
        
        guard let compoundUnit = unit as? SCompoundUnit else {
            copy.unitToPower[unit as! SBasicUnit, default: 0] += factor
            return copy
        }
        
        for (unit, power) in compoundUnit.unitToPower {
            copy.unitToPower[unit, default: 0] += power * factor
            
            if copy.unitToPower[unit] == 0 {
                copy.unitToPower[unit] = nil
            }
        }
        return copy
    }
    
    public func subtracting<UnitType: SUnitRepresentable>(other unit: UnitType, by factor: Int = 1)-> SCompoundUnit {
        var copy = self
        
        guard let compoundUnit = unit as? SCompoundUnit else {
            copy.unitToPower[unit as! SBasicUnit, default: 0] -= factor
            return copy
        }
        
        for (unit, power) in compoundUnit.unitToPower {
            copy.unitToPower[unit, default: 0] -= power * factor
            
            if copy.unitToPower[unit] == 0 {
                copy.unitToPower[unit] = nil
            }
        }
        return copy
    }
    
    public func multipying(by factor: Int)-> SCompoundUnit {
        return SCompoundUnit(dictionaryRepresentation: unitToPower.mapValues(factor.unsafeMultiplied))
    }
    
    public func canConvert<UnitType: SUnitRepresentable>(to unit: UnitType) -> Bool {
        guard let targetUnit = unit as? SCompoundUnit else {
            return false
        }
        
        return baseUnitToPower == targetUnit.baseUnitToPower
    }
    
    public func convertToBase(value: CComplex) -> CComplex {
        var finalValue = value
        
        for (unit, power) in unitToPower {
            if power > 0 {
                for _ in 1...power {
                    finalValue = unit.convertToBase(value: finalValue)
                }
            }
            else {
                for _ in 1...abs(power) {
                    finalValue = unit.convertFromBase(value: finalValue)
                }
            }
        }
        
        return finalValue
    }
    
    public func convertFromBase(value: CComplex) -> CComplex {
        var finalValue = value
        
        for (unit, power) in unitToPower {
            if power > 0 {
                for _ in 1...power {
                    finalValue = unit.convertFromBase(value: finalValue)
                }
            }
            else {
                for _ in 1...power {
                    finalValue = unit.convertToBase(value: finalValue)
                }
            }
        }
        
        return finalValue
    }
    
    // MARK: Public Static Methods
    public static func ==(_ lhs: SCompoundUnit, _ rhs: SCompoundUnit)-> Bool {
        return lhs.unitToPower == rhs.unitToPower
    }
    
}
