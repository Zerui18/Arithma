//
//  AMBasicUnit.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import HPAKit

public final class AMBasicUnit: AMUnitRepresentable, Hashable {
    
    public let unitId: String
    public var baseUnit: AMBasicUnit!
    public var relativeWorth: Double
    
    /**
     Constructing a AMBasicUnit with a unitId, and optional baseUnitId & convertionRate if the unit is derived (non-si unit).
     */
    fileprivate init(unitId: String, baseUnit: AMBasicUnit? = nil, relativeWorth: Double? = nil) {
        self.unitId = unitId
        self.relativeWorth = relativeWorth ?? 1.0
        self.baseUnit = baseUnit
                
        if self.baseUnit == nil {
            self.baseUnit = self
        }
        assert((baseUnit != nil && relativeWorth != nil) || (baseUnit == nil && relativeWorth == nil),
               "Setting a base NumiUnit requires both baseUnit & relativeWorth to be non-nil.")
    }
    
    public var hashValue: Int {
        return unitId.hashValue
    }
        
    public func canConvert<UnitType: AMUnitRepresentable>(to unit: UnitType) -> Bool {
        // base unit can only be converted to abother baseUnit of the same origin
        if let targetUnit = unit as? AMBasicUnit {
            return targetUnit == self ||
                targetUnit.baseUnit == self ||
                targetUnit == self.baseUnit
        }
        return false
    }
    
    public func convertToBase(value: HPAComplex) -> HPAComplex {
        return HPAComplex(floatLiteral: relativeWorth) * value
    }
    
    public func convertFromBase(value: HPAComplex) -> HPAComplex {
        return  value / HPAComplex(floatLiteral: relativeWorth)
    }
    
    public static func ==(_ lhs: AMBasicUnit, _ rhs: AMBasicUnit)-> Bool {
        return lhs.unitId == rhs.unitId
    }
    
    public var description: String {
        return unitId
    }
    
}

// MARK: Codable Conformance
extension AMBasicUnit: Codable {}

// MARK: Static
extension AMBasicUnit {
    
    public static var allUnits = Set<AMBasicUnit>()
    public static func getUnit(for id: String)-> AMBasicUnit? {
        return allUnits.first(where: {$0.unitId.elementsEqual(id)})
    }
    
}

// MARK: Creating Units
prefix operator +>
public prefix func +>(_ unitId: String)-> AMBasicUnit {
    let newBaseUnit = AMBasicUnit(unitId: unitId)
    AMBasicUnit.allUnits.insert(newBaseUnit)
    return newBaseUnit
}

infix operator ~~: AdditionPrecedence
public func ~~(_ baseUnit: AMBasicUnit, _ properties: (String, Double))-> AMBasicUnit {
    let newScaledUnit = AMBasicUnit(unitId: properties.0, baseUnit: baseUnit, relativeWorth: properties.1)
    AMBasicUnit.allUnits.insert(newScaledUnit)
    return baseUnit
}
