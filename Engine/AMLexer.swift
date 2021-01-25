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
public final class AMLexer {
    
    enum Token {
        case link(AMValue), value(HPAReal), unit(AMBasicUnit), parensOpen, parensClose, `operator`(AMValue.Operator), function(AMValue.Function), identifier(String), imaginaryUnit
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
        "^": .operator(.exponentiate), "i": .imaginaryUnit,
        "e": .value(.e), "π": .value(.pi)
    ]
    
    // MARK: Private Computed-properties
    
    private var currentChar: Character? {
        return index<endIndex ? textStorage.string[index] : nil
    }
    
    private var isIndented: Bool {
        let baselineOffset = textStorage.attribute(.baselineOffset,
                                                   at: index.encodedOffset, effectiveRange: nil) as? Double ?? 0.0
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
    @inline(__always)
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
    
    @inline(__always)
    private func readNumberOrIdentifier() -> String {
        
        let cChar = currentChar!
        var str = ""
        
        @inline(__always)
        func readNumber() {
            while let char = currentChar, char.isNumber || char == "." {
                str.append(char)
                advanceIndex()
                if postInsertBlock != nil {
                    break
                }
            }
        }
        
        @inline(__always)
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
            guard postInsertBlock == nil else {
                return str
            }
        }
        readNumber()
        
        return str
    }
    
    @inline(__always)
    private func readLink()-> AMLexer.Token? {
        var range = NSRange()
        guard let psuedoLink = textStorage.attribute(.link,
                                                     at: index.encodedOffset,
                                                     effectiveRange: &range),
              let data = Data(base64Encoded: (psuedoLink as! URL).lastPathComponent),
              let value = try? JSONDecoder().decode(AMValue.self,
                                                    from: data)
        else { return nil }
        
        let token = Token.link(value)
        setHighlight(with: token, for: range.length)
        index = textStorage.string.index(index, offsetBy: range.length)
        return token
    }
    
    @inline(__always)
    private func setHighlight(with token: AMLexer.Token, for count: Int, starting index: Int? = nil) {
        let range = NSRange(location: index ?? self.index.encodedOffset, length: count)
        textStorage.addAttributes([.foregroundColor: token.syntaxColor], range: range)
    }
    
    @inline(__always)
    private func advanceToNextToken() -> AMLexer.Token? {
        
        // If we hit the end of the input, then we're done
        guard currentChar != nil else {
            return nil
        }
        
        // skip all spaces / possibly until end
        while currentChar?.isSpace ?? false {
            advanceIndex()
        }
        
        // check again if at end
        guard let char = currentChar else {
            return nil
        }
        
        // try to read link before anything
        if let link = readLink() {
            return link
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
        if currentChar != nil && isIndented {
            tokens.append(.operator(.exponentiate))
            tokens.append(.parensOpen)
        }
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
