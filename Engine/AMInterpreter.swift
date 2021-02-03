//
//  AMInterpreter.swift
//  NumiBackend
//
//  Created by Chen Zerui on 29/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import HPAKit
import Settings

// MARK: AMInterpreterDelegate protocol
public protocol AMInterpreterDelegate: class {
    func interpreterDidReEvaluate(value: AMValue?, error: Error?)
}

// MARK: AMInterpreter class
public final class AMInterpreter: NSObject {
    
    public struct Expression {
        init(tokens: [AMLexer.Token], assigningResultTo variableId: String? = nil) {
            self.tokens = tokens
            self.newVariableId = variableId
        }
        
        let tokens: [AMLexer.Token]
        
        public var newVariableId: String?
    }
    
    // MARK: Public Properties
    public weak var delegate: AMInterpreterDelegate?
    
    // MARK: Private Properties
    fileprivate static var allInterpreters = [AMInterpreter]()
    private var tokens = [AMLexer.Token]()
    private var index = 0
    private var stopFlag = false
    
    private var referencingVariables = Set<String>()
    
    private var lastVariableId: String?
    private var lastValue: AMValue?
    
    private let operatorPrecedence: [AMValue.Operator: Int] = [
        .add : 20,
        .subtract : 20,
        .multiply : 40,
        .divide : 40,
        .exponentiate : 60,
        .exponentiate10: 80
    ]
    
    // MARK: Private Computed-properties
    private var tokensAvailable: Bool {
        return index < tokens.count
    }
    
    private var currentToken: AMLexer.Token {
        return tokens[index]
    }
    
    // MARK: Public Static-methods
    public static func setup() {
        _ = NotificationCenter.default.addObserver(forName: .calcModeChanged, object: nil, queue: OperationQueue.main) {_ in
            AMInterpreter.allInterpreters.forEach {
                $0.reEvaluate()
            }
        }
    }
    
    // MARK: Init
    public override init() {
        super.init()
        AMInterpreter.allInterpreters.append(self)
    }
    
    // MARK: Private Methods
    @inline(__always)
    private func popCurrentToken()-> AMLexer.Token {
        defer {
            index += 1
        }
        return currentToken
    }
    
    @inline(__always)
    private func interpretValue() throws -> AMValue {
        guard tokensAvailable, case let AMLexer.Token.value(value) = popCurrentToken() else {
            throw ParseError.expectedNumber
        }
        return AMValue(value: value.toComplex)
    }
    
    @inline(__always)
    private func interpretUnit() throws -> AMCompoundUnit {
        guard tokensAvailable, case AMLexer.Token.unit = currentToken else {
            throw ParseError.expectedNumber
        }
        
        var compoundUnit = AMCompoundUnit()
        
        while tokensAvailable, case let AMLexer.Token.unit(unit) = currentToken {
            index += 1
            
            if tokensAvailable, case AMLexer.Token.operator(.exponentiate) = currentToken {
                index += 1
                
                let value = try interpretCurrentExpression(outerExprPrecedence: 60)
                guard !value.hasUnit else {
                    throw ParseError.unexpectedUnit
                }
                
                let power = value.value
                
                guard power.isReal, power.re == power.re.floor else {
                    throw ParseError.expectedInteger
                }
                
                compoundUnit = compoundUnit.adding(other: unit, by: try Int(safelyWith: power.re.toDouble))
            }
            else {
                compoundUnit = compoundUnit.adding(other: unit)
            }
            
        }
        
        return compoundUnit
    }
    
    @inline(__always)
    private func interpretParentheses() throws -> AMValue {
        guard tokensAvailable, case AMLexer.Token.parensOpen = popCurrentToken() else {
            throw ParseError.expectedCharacter("(")
        }
        
        // throw Error if empty bracket (else will enter infinite loop)
        if tokensAvailable, case AMLexer.Token.parensClose = currentToken {
            throw ParseError.expectedExpression
        }
        
        let exp = try interpretCurrentExpression()
        
        guard tokensAvailable, case AMLexer.Token.parensClose = popCurrentToken() else {
            throw ParseError.expectedCharacter(")")
        }
        
        return exp
    }
    
    @inline(__always)
    private func interpretFunction() throws -> AMValue {
        
        guard case let AMLexer.Token.function(functionName) = popCurrentToken() else {
            throw ParseError.expectedExpression
        }
        
        let argument = try interpretParentheses()
        
        return try argument.performing(functionName)
    }
    
    @inline(__always)
    private func interpretPrimaryTokenType() throws -> AMValue {
        guard tokensAvailable else {
            throw ParseError.expectedExpression
        }
        
        switch currentToken {
        case .link(let value):
            index += 1
            return value
        case .value:
            return try interpretValue()
        case .parensOpen:
            return try interpretParentheses()
        case .function:
            return try interpretFunction()
        case .operator(.subtract):
            index += 1
            
            let value = try interpretPrimaryTokenType()
            let negativeValue = AMValue(value: -value.value, unit: value.unit)
            
            return negativeValue
        case .identifier(let variableId):
            index += 1
            return try getVariable(forId: variableId)
        case .unit:
            return AMValue(value: HPAComplex(re: 1, im: 0), unit: try interpretUnit())
        case .imaginaryUnit:
            index += 1
            return AMValue(value: HPAComplex(re: 0, im: 1))
        default:
            throw ParseError.expectedExpression
        }
    }
    
    @inline(__always)
    private func getCurrentTokenPrecedence() throws -> Int {
        
        guard tokensAvailable, case let AMLexer.Token.operator(op) = currentToken else {
            return -1
        }
        
        let precedence = operatorPrecedence[op]!
        
        return precedence
    }
    
    @inline(__always)
    private func interpretBinaryOperation(lhs: AMValue, exprPrecedence: Int = 0) throws -> AMValue {
        
        while true {
            let tokenPrecedence = try getCurrentTokenPrecedence()
            
            if tokenPrecedence <= exprPrecedence {
                // sets stopFlag to on, thus stopping evaluation in current recursion level
                stopFlag = true
                return lhs
            }
            
            // this shouldn't fail if the above check passes..
            guard case let AMLexer.Token.operator(op) = popCurrentToken() else {
                throw ParseError.expectedOperator
            }
            
            var rhs = try interpretCurrentExpression(outerExprPrecedence: tokenPrecedence)
            let nextPrecedence = try getCurrentTokenPrecedence()
            
            if tokenPrecedence < nextPrecedence {
                rhs = try interpretBinaryOperation(lhs: rhs, exprPrecedence: tokenPrecedence)
            }
            
            return try lhs.performing(op, withRhs: rhs)
        }
    }
    
    @inline(__always)
    private func getVariable(forId id: String) throws -> AMValue {
        referencingVariables.insert(id)
        
        guard let value = variablesToValue[id] else {
            throw ParseError.unknownSymbol(id)
        }
        return value
    }
    
    @inline(__always)
    private func interpretCurrentExpression(outerExprPrecedence: Int = 0) throws -> AMValue {
        
        lastValue = nil
        var currentValue = try interpretPrimaryTokenType()
        
        while tokensAvailable {
            
            // to avoid infinite loop caused by unexpected currentToken
            switch currentToken {
            case .operator:
                // if nested into 'auto multiply', start search with multiply precedence
                currentValue = try interpretBinaryOperation(lhs: currentValue, exprPrecedence: outerExprPrecedence)
                // checks if evaluation should stop
                if stopFlag {
                    stopFlag = false
                    return currentValue
                }
            case .parensClose:
                // return upon encountering close parenthesis
                return currentValue
            case .link, .unit, .value, .identifier, .function, .parensOpen, .imaginaryUnit:
                // check if auto-multiply possible
                guard outerExprPrecedence <= 40 else {
                    return currentValue
                }
                // try to evaluate succeeding partial-expression, multiplying it with current
                let value = try interpretCurrentExpression(outerExprPrecedence: 40)
                currentValue = try currentValue.performing(AMValue.Operator.multiply, withRhs: value)
            }
            
        }
        
        if let varId = lastVariableId {
            setVariable(forName: varId, value: currentValue)
        }
        
        lastValue = currentValue
        return currentValue
    }
    
    @inline(__always)
    fileprivate func isReferencing(_ id: String)-> Bool {
        return referencingVariables.contains(id)
    }
    
    @inline(__always)
    fileprivate func reEvaluate() {
        
        self.index = 0
        
        do {
            let value = try interpretCurrentExpression()
            
            delegate?.interpreterDidReEvaluate(value: value, error: nil)
        }
        catch {
            if lastVariableId != nil {
                removeVariable(forName: lastVariableId!)
            }
            delegate?.interpreterDidReEvaluate(value: nil, error: error)
        }
    }
    
    
    // MARK: Public Methods
    
    /**
     Evaluate the expression generated by a AMLexer.
     - parameters:
        - expression: an Expression object
     - throws: error of ParseError if the evaluation fails
     - returns: a AMValue object containing the result
     */
    public func evaluate(_ expression: Expression) throws -> AMValue {
        
        referencingVariables.removeAll()
        tokens.removeAll()
        
        self.index = 0
        if lastVariableId != nil {
            removeVariable(forName: lastVariableId!)
            lastVariableId = nil
        }
        
        guard !expression.tokens.isEmpty else {
            throw ParseError.expectedExpression
        }
        
        self.tokens = expression.tokens
        
        if let newVarId = expression.newVariableId {
            guard variablesToValue[newVarId] == nil else {
                throw ParseError.duplicateDeclaration(newVarId)
            }
            
            lastVariableId = expression.newVariableId
        }
        
        return try interpretCurrentExpression()
    }
    
    /**
     Sets the variable id that the receiver asigns to to the given value. Triggers re-evaluation of tree of interpreters that either directly, or indirectly references the old variable (if applicable).
     - parameters:
        - variable: The variable id of the new variable
     */
    public func setAssign(to variable: String?) {
        if lastVariableId != nil {
            removeVariable(forName: lastVariableId!)
        }
        
        lastVariableId = variable
        if lastValue != nil {
            setVariable(forName: variable!, value: lastValue!)
        }
    }
    
    // MARK: Deinit
    deinit {
        if let oldVaribaleId = lastVariableId {
            removeVariable(forName: oldVaribaleId)
        }
    }
    
}

// MARK: Private Global Functions
fileprivate func setVariable(forName name: String, value: AMValue) {
    variablesToValue[name] = value
    for interpreter in AMInterpreter.allInterpreters where interpreter.isReferencing(name) {
        interpreter.reEvaluate()
    }
}

fileprivate func removeVariable(forName name: String) {
    variablesToValue[name] = nil
    for interpreter in AMInterpreter.allInterpreters where interpreter.isReferencing(name) {
        interpreter.reEvaluate()
    }
}

fileprivate var variablesToValue = [String: AMValue]()

