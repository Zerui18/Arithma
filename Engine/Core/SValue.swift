//
//  SValue.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import ExtMathLib
import CComplex
import NumCodeSettings

public class SValue: Equatable, CustomStringConvertible {
    
    public var value: CComplex
    public var unit: SCompoundUnit
    public weak var boundLabel: UIView? {
        didSet {
            boundLabel?.setValue(attributedDescription, forKey: "attributedText")
        }
    }
    
    /**
     Initializes a SValue instance with a scalar value and a unit
     */
    public init(value: CComplex, unit: SCompoundUnit = .init()) {
        self.value = value
        self.unit = unit
        
        NotificationCenter.default.addObserver(forName: .displayModeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.boundLabel?.setValue(self?.attributedDescription, forKey: "attributedText")
        }
    }
    
    var hasUnit: Bool {
        return !unit.unitToPower.isEmpty
    }
    
    func valueInBaseUnit() -> CComplex {
        return unit.convertToBase(value: value)
    }
    
    /**
     Create a new SValue representing the receiver's value in the given unit. The target unit must share/be the baseUnit of the receiver.
     - parameters:
        - unit: the desired unit
     - throws: an error if unit cast is not possible
     - returns: the newly constructed NumiUnit instance
     */
    public func convertedTo(unit: SCompoundUnit) throws -> SValue {
        
        guard self.unit.canConvert(to: unit) else {
            throw OperationError.unitConversionFailed(self.unit, unit)
        }
        let baseUnitValue = valueInBaseUnit()
        let convertedValue = unit.convertFromBase(value: baseUnitValue)

        return SValue(value: convertedValue, unit: unit)
    }
    
    public static func ==(_ lhs: SValue, _ rhs: SValue)-> Bool {
        return lhs.value == rhs.value && lhs.unit == rhs.unit
    }
    
    
    /**
     Debug description of the receiver's value in base units.
     */
    public var description: String {
        return valueInBaseUnit().description + unit.description
    }
    
    /**
     Create a NSMutableAttributedString for UI display of the receiver's value.
     */
    public var attributedDescription: NSMutableAttributedString {
        let str = valueInBaseUnit().formatted()
        unit.addUnitDescription(to: str)
        return str
    }

}
