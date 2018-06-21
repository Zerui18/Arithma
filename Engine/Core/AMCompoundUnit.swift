//
//  AMCompoundUnit.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import HPAKit

public struct AMCompoundUnit: AMUnitRepresentable {
    
    // MARK: Internal Properties
    var unitToPower = [AMBasicUnit: Int]()
    var baseUnitToPower: [AMBasicUnit: Int] {
        var dict = [AMBasicUnit: Int]()
        
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
    
    public init(containingBaseUnit unit: AMBasicUnit, ofPower power: Int = 1) {
        unitToPower[unit] = power
    }
    
    public init(dictionaryRepresentation: [AMBasicUnit: Int]) {
        unitToPower = dictionaryRepresentation
    }
    
    // MARK: Public Methods
    public func adding<UnitType: AMUnitRepresentable>(other unit: UnitType, by factor: Int = 1)-> AMCompoundUnit {
        var copy = self
        
        guard let compoundUnit = unit as? AMCompoundUnit else {
            copy.unitToPower[unit as! AMBasicUnit, default: 0] += factor
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
    
    public func subtracting<UnitType: AMUnitRepresentable>(other unit: UnitType, by factor: Int = 1)-> AMCompoundUnit {
        var copy = self
        
        guard let compoundUnit = unit as? AMCompoundUnit else {
            copy.unitToPower[unit as! AMBasicUnit, default: 0] -= factor
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
    
    public func multipying(by factor: Int)-> AMCompoundUnit {
        return AMCompoundUnit(dictionaryRepresentation: unitToPower.mapValues(factor.unsafeMultiplied))
    }
    
    public func canConvert<UnitType: AMUnitRepresentable>(to unit: UnitType) -> Bool {
        guard let targetUnit = unit as? AMCompoundUnit else {
            return false
        }
        
        return baseUnitToPower == targetUnit.baseUnitToPower
    }
    
    public func convertToBase(value: HPAComplex) -> HPAComplex {
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
    
    public func convertFromBase(value: HPAComplex) -> HPAComplex {
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
    public static func ==(_ lhs: AMCompoundUnit, _ rhs: AMCompoundUnit)-> Bool {
        return lhs.unitToPower == rhs.unitToPower
    }
    
}
