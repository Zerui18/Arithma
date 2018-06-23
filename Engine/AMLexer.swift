//
//  AMLexer.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import HPAKit

// MARK: AMLexer class
public class AMLexer {
    
    enum Token {
        case value(HPAReal), unit(AMBasicUnit), parensOpen, parensClose, `operator`(AMValue.Operator), function(AMValue.Function), identifier(String), imaginaryUnit
    }
    
    // MARK: Private Properties
    private let textStorage: NSTextStorage
    private var index: String.Index
    private let endIndex: String.Index
    private let allowUnits: Bool
    
    private var newVariableName: String?
    
    private var tokens = [AMLexer.Token]()
    private var lastIndented = false
    
    private var postInsertBlock: (()-> Void)?
    
    private let singleCharTokenMapping: [Character: AMLexer.Token] = [
        "(": .parensOpen, ")": .parensClose,
        "+": .operator(.add), "-": .operator(.subtract),
        "×": .operator(.multiply), "÷": .operator(.divide),
        "^": .operator(.exponentiate), "i": .imaginaryUnit
    ]
    
    // MARK: Private Computed-properties
    
    private var currentChar: Character? {
        return index<endIndex ? textStorage.string[index] : nil
    }
    
    private var isIndented: Bool {
        let baselineOffset = textStorage.attribute(NSAttributedStringKey.baselineOffset, at: index.encodedOffset, effectiveRange: nil) as? Double ?? 0.0
        return baselineOffset != 0.0
    }
    
    // MARK: Init
    public init(textStorage: NSTextStorage, allowUnits: Bool = true, variableName: String?) {
        self.textStorage = textStorage
        self.index = textStorage.string.startIndex
        self.endIndex = textStorage.string.endIndex
        self.allowUnits = allowUnits
        self.newVariableName = variableName
    }
    
    // MARK: Private Methods
    private func advanceIndex() {
        index = textStorage.string.index(after: index)
        
        guard index != endIndex else {
            return
        }
        
        if !lastIndented && isIndented {
            postInsertBlock = {
                self.tokens.append(.operator(.exponentiate))
                self.tokens.append(.parensOpen)
            }
        }
        else if lastIndented && !isIndented {
            postInsertBlock = {
                self.tokens.append(.parensClose)
            }
        }
        
        lastIndented = isIndented
    }
    
    private func readNumberOrIdentifier() -> String {
        
        let cChar = currentChar!
        var str = ""
        
        func readNumber() {
            while let char = currentChar, char.isNumber || char == "." {
                str.append(char)
                advanceIndex()
                if postInsertBlock != nil {
                    break
                }
            }
        }
        
        func readLetters() {
            while let char = currentChar, char.isAlpha {
                str.append(char)
                advanceIndex()
                if postInsertBlock != nil {
                    break
                }
            }
        }
        
        if cChar.isAlpha {
            readLetters()
            
            // "e" is counted as an operator
            guard postInsertBlock == nil && str != "e" else {
                return str
            }
        }
        readNumber()
        
        return str
    }
    
    private func setHighlight(with token: AMLexer.Token, for count: Int, starting index: Int? = nil) {
        textStorage.addAttributes([.foregroundColor: token.syntaxColor], range: NSRange(location: index ?? self.index.encodedOffset, length: count))
    }
    
    private func advanceToNextToken() -> AMLexer.Token? {

        if currentChar?.isSpace ?? false {
            advanceIndex()
        }
        
        // If we hit the end of the input, then we're done
        guard let char = currentChar else {
            return nil
        }
        
        // try to match for single-char token
        if let token = singleCharTokenMapping[char] {
            setHighlight(with: token, for: 1)
            advanceIndex()
            return token
        }
        
        // parse all kinds of other expressions
        if char.isAlphanumeric {
            let startIndex = index.encodedOffset
            
            let str = readNumberOrIdentifier()
            let token: AMLexer.Token
            
            if let dblVal = HPAReal(str) {
                token = .value(dblVal)
            }

            else if let function = AMValue.Function(rawValue: str) {
                token = .function(function)
            }
                
            else if allowUnits, let unit = AMBasicUnit.getUnit(for: str) {
                token = .unit(unit)
            }
            
            else if  str == "e" {
                token = .operator(.exponentiate10)
            }

            else {
                token = .identifier(str)
            }
            
            setHighlight(with: token, for: str.count, starting: startIndex)
            
            return token
        }
        else {
            
            let token = Token.identifier(String(char))
            
            setHighlight(with: token, for: 1)
            advanceIndex()
            return token
        }
    }
    
    // MARK: Public Methods
    public func lex() -> AMInterpreter.Expression {
        while let token = advanceToNextToken() {
            tokens.append(token)
            
            postInsertBlock?()
            postInsertBlock = nil
        }
        
        if !tokens.isEmpty {
            tokens.append(.parensClose)
        }
        return AMInterpreter.Expression(tokens: tokens, assigningResultTo: newVariableName)
    }
}

// MARK: NSRange + isValid
fileprivate extension NSRange {
    
    var isValid: Bool {
        return lowerBound < upperBound
    }
    
}
