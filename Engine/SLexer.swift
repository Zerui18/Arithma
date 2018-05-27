//
//  SLexer.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import HPAKit

// MARK: SLexer class
public class SLexer {
    
    enum Token {
        case value(HPAReal), unit(SBasicUnit), parensOpen, parensClose, `operator`(SValue.Operator), function(SValue.Function), identifier(String), imaginaryUnit
    }
    
    // MARK: Private Properties
    private let textStorage: NSTextStorage
    private var index: String.Index
    private let endIndex: String.Index
    
    private var newVariableName: String?
    
    private var tokens = [SLexer.Token]()
    private var lastIndented = false
    
    private var postInsertBlock: (()-> Void)?
    
    private let singleCharTokenMapping: [Character: SLexer.Token] = [
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
    public init(textStorage: NSTextStorage, variableName: String?) {
        self.textStorage = textStorage
        self.index = textStorage.string.startIndex
        self.endIndex = textStorage.string.endIndex
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
            
            guard postInsertBlock == nil else {
                return str
            }
        }
        readNumber()
        
        return str
    }
    
    private func setHighlight(with token: SLexer.Token, for count: Int, starting index: Int? = nil) {
        textStorage.addAttributes([.foregroundColor: token.syntaxColor], range: NSRange(location: index ?? self.index.encodedOffset, length: count))
    }
    
    private func advanceToNextToken(_ willBeFirst: Bool = false) -> SLexer.Token? {

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
            let token: SLexer.Token
            
            if let dblVal = HPAReal(str) {
                token = .value(dblVal)
            }

            else if let function = SValue.Function(rawValue: str) {
                token = .function(function)
            }
                
            else if let unit = SBasicUnit.getUnit(for: str) {
                token = .unit(unit)
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
    public func lex() -> SInterpreter.Expression {
        while let token = advanceToNextToken() {
            tokens.append(token)
            
            postInsertBlock?()
            postInsertBlock = nil
        }
        
        if !tokens.isEmpty {
            tokens.append(.parensClose)
        }
        return SInterpreter.Expression(tokens: tokens, assigningResultTo: newVariableName)
    }
}

// MARK: NSRange + isValid
fileprivate extension NSRange {
    
    var isValid: Bool {
        return lowerBound < upperBound
    }
    
}
