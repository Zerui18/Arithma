//
//  SBasicUnit.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import HPAKit

public class SBasicUnit: SUnitRepresentable, Hashable {
    
    public let unitId: String
    public var baseUnit: SBasicUnit!
    public var relativeWorth: Double
    
    /**
     Constructing a SBasicUnit with a unitId, and optional baseUnitId & convertionRate if the unit is derived (non-si unit).
     */
    fileprivate init(unitId: String, baseUnit: SBasicUnit? = nil, relativeWorth: Double? = nil) {
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
        
    public func canConvert<UnitType: SUnitRepresentable>(to unit: UnitType) -> Bool {
        // base unit can only be converted to abother baseUnit of the same origin
        if let targetUnit = unit as? SBasicUnit {
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
    
    public static func ==(_ lhs: SBasicUnit, _ rhs: SBasicUnit)-> Bool {
        return lhs.unitId == rhs.unitId
    }
    
    public var description: String {
        return unitId
    }
    
}


extension SBasicUnit {
    
    public static var allUnits = Set<SBasicUnit>()
    public static func getUnit(for id: String)-> SBasicUnit? {
        return allUnits.first(where: {$0.unitId.elementsEqual(id)})
    }
    
}

prefix operator +>
public prefix func +>(_ unitId: String)-> SBasicUnit {
    let newBaseUnit = SBasicUnit(unitId: unitId)
    SBasicUnit.allUnits.insert(newBaseUnit)
    return newBaseUnit
}

infix operator ~~: AdditionPrecedence
public func ~~(_ baseUnit: SBasicUnit, _ properties: (String, Double))-> SBasicUnit {
    let newScaledUnit = SBasicUnit(unitId: properties.0, baseUnit: baseUnit, relativeWorth: properties.1)
    SBasicUnit.allUnits.insert(newScaledUnit)
    return baseUnit
}
