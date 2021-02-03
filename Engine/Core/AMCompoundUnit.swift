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
    /// An equivalent representation of this unit composed using base units.
    var baseUnitToPower: [AMBasicUnit: Int] {
        var dict = [AMBasicUnit: Int]()
        
        for (unit, power) in unitToPower {
            dict[unit.baseUnit, default: 0] += power
            
            // Clear up unused units.
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
    
    public init(withBaseUnit unit: AMBasicUnit, ofPower power: Int = 1) {
        unitToPower[unit] = power
    }
    
    public init(dictionaryRepresentation: [AMBasicUnit: Int]) {
        unitToPower = dictionaryRepresentation
    }
    
    // MARK: Public Methods
    public func adding<UnitType: AMUnitRepresentable>(other unit: UnitType, by factor: Int = 1)-> AMCompoundUnit {
        var copy = self
        
        guard let compoundUnit = unit as? AMCompoundUnit else {
            let unit = unit as! AMBasicUnit
            copy.unitToPower[unit, default: 0] += factor
            return copy
        }
        
        for (unit, power) in compoundUnit.unitToPower {
            copy.unitToPower[unit, default: 0] += power * factor
        }
        return copy
    }
    
    public func subtracting<UnitType: AMUnitRepresentable>(other unit: UnitType, by factor: Int = 1)-> AMCompoundUnit {
        return adding(other: unit, by: -1)
    }
    
    public func multipying(by factor: Int)-> AMCompoundUnit {
        return AMCompoundUnit(dictionaryRepresentation: unitToPower.mapValues { factor * $0 })
    }
    
    public func canConvert<UnitType: AMUnitRepresentable>(to unit: UnitType) -> Bool {
        guard let targetUnit = unit as? AMCompoundUnit else {
            return false
        }
        
        return baseUnitToPower == targetUnit.baseUnitToPower
    }
    
    public func convertToBase(value: HPAComplex) -> HPAComplex {
        var finalValue = value
        
        for (unit, power) in unitToPower where power != 0 {
            finalValue = finalValue * HPAComplex(unit.relativeWorth).pow(e: HPAComplex(power))
        }
        
        return finalValue
    }
    
    public func convertFromBase(value: HPAComplex) -> HPAComplex {
        var finalValue = value
        
        for (unit, power) in unitToPower where power != 0 {
            finalValue = finalValue / HPAComplex(unit.relativeWorth).pow(e: HPAComplex(power))
        }
        
        return finalValue
    }
    
    // MARK: Equatable Conformance
    public static func ==(_ lhs: AMCompoundUnit, _ rhs: AMCompoundUnit)-> Bool {
        return lhs.unitToPower == rhs.unitToPower
    }
    
}

// MARK: Codable
extension AMCompoundUnit: Codable {}
