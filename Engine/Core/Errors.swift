//
//  Errors.swift
//  NumiBackend
//
//  Created by Chen Zerui on 3/2/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation

public protocol SError: Error {
    var description: String {get}
}

extension SInterpreter {
    
    public enum ParseError: SError {
        case expectedNumber, expectedCharacter(Character), expectedExpression, unknownOperator(Character), expectedOperator, unknownSymbol(String), duplicateDeclaration(String), unexpectedUnit, expectedInteger
        
        public var description: String {
            switch self {
            case .expectedNumber:
                return "Expected number"
            case .expectedInteger:
                return "Expected integer"
            case .expectedCharacter(let char):
                return "Expected character '\(char)'"
            case .expectedExpression:
                return "Expected expression"
            case .unknownOperator(let char):
                return "Unknown operator '\(char)'"
            case .expectedOperator:
                return "Expected operator"
            case .unexpectedUnit:
                return "Unexpected unit"
            case .unknownSymbol(let str):
                return "Unknown symbol \"\(str)\""
            case .duplicateDeclaration(let varId):
                return "Duplicate definition \"\(varId)\""
            }
        }
    }
    
}

extension SValue {
    
    public enum OperationError: SError {
        case unitConversionFailed(SCompoundUnit, SCompoundUnit), unexpectedUnit
        
        public var description: String {
            switch self {
            case .unitConversionFailed(let from, let to):
                return "Can't convert from \(from) to \(to)"
            case .unexpectedUnit:
                return "Unexpected unit"
            }
        }
    }
    
}
