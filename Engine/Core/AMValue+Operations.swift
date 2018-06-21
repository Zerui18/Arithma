//
//  AMValue+Operations.swift
//  ArithmaBackend
//
//  Created by Chen Zerui on 2/2/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import HPAKit
import Settings

protocol OperationRepresentable {
    func run(on values: [HPAComplex])-> HPAComplex
}

extension AMValue {
    enum Operator: Character, OperationRepresentable {
        case add = "+", subtract = "-", multiply = "×", divide = "÷", exponentiate = "^"
        
        func run(on values: [HPAComplex]) -> HPAComplex {
            switch self {
            case .add:
                return values[0]+values[1]
            case .subtract:
                return values[0]-values[1]
            case .multiply:
                return values[0]*values[1]
            case .divide:
                return values[0]/values[1]
            case .exponentiate:
                return values[0].pow(e: values[1])
            }
        }
    }
    
    enum Function: String, OperationRepresentable {
        case sin, cos, tan, asin, acos, atan, ln, lg, sqrt, exp, abs
        
        func run(on values: [HPAComplex])-> HPAComplex {
            let value = values[0]
            
            switch self {
            case .sin:
                return value.sin
            case .cos:
                return value.cos
            case .tan:
                return value.tan
            case .asin:
                return value.asin
            case .acos:
                return value.acos
            case .atan:
                return value.atan
            case .ln:
                return value.ln
            case .lg:
                return value.lg
            case .sqrt:
                return value.sqrt
            case .exp:
                return value.exp
            case .abs:
                return HPAComplex(re: value.abs, im: 0)
            }
        }
    }
}

extension AMValue {
    
    func performing(_ op: OperationRepresentable, withRhs rhs: AMValue? = nil) throws -> AMValue {
        
        let operand1Value = self
        
        if let `operator` = op as? Operator {
            let operand2Value = rhs!
            
            // 2 operands
            let finalUnit: AMCompoundUnit
            
            let operand1DoubleValue: HPAComplex, operand2DoubleValue: HPAComplex
            
            switch `operator` {
            case .add, .subtract:
                // cannot stack units, only operate on values with the same units
                
                operand2DoubleValue = operand2Value.value
                
                operand1DoubleValue = try operand1Value.convertedTo(unit: operand2Value.unit).value
                
                finalUnit = operand2Value.unit
                
            case .multiply, .divide:
                
                // can stack units
                operand1DoubleValue = operand1Value.value
                operand2DoubleValue = operand2Value.value
                
                // stack/subtract units from both values
                
                if `operator` == .multiply {
                    finalUnit = operand1Value.unit.adding(other: operand2Value.unit)
                }
                else {
                    finalUnit = operand1Value.unit.subtracting(other: operand2Value.unit)
                }
                
            case .exponentiate:
                // it does not make sense for the power to have unit
                guard !operand2Value.hasUnit else {
                    throw OperationError.unexpectedUnit
                }
                
                operand1DoubleValue = operand1Value.value
                operand2DoubleValue = operand2Value.value
                
                finalUnit = operand1Value.unit.multipying(by: Int(operand2DoubleValue.abs.toDouble))
                
            }
            
            let value = `operator`.run(on: [operand1DoubleValue, operand2DoubleValue])
            return AMValue(value: value, unit: finalUnit)
        }
        else {
            // 1 operand
            let function = op as! Function
            let value: HPAComplex
            
            switch function {
            case .sin, .cos, .tan:
                let input = AMSettings.shared.isDegreeMode ? operand1Value.value.toRadian:operand1Value.value
                value = function.run(on: [input])
            case .asin, .acos, .atan:
                let output = function.run(on: [operand1Value.value])
                value = AMSettings.shared.isDegreeMode ? output.toDegree:output
            default:
                value = function.run(on: [operand1Value.value])
            }
            return AMValue(value: value, unit: operand1Value.unit)
        }
        
    }
    
}

