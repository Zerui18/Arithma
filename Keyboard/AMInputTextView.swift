//
//  AMInputTextView.swift
//  ArithmaKeyboard
//
//  Created by Chen Zerui on 15/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine

// MARK: Callback Types
public typealias AMResultUpdateHandler = (AMValue?, Error?) -> Void
public typealias AMTextChangedHandler = () -> Void
public typealias AMEmptyBackspaceHandler = ()-> Void

// MARK: AMInputTextView
/// Custom UITextView subclass which integrates with AMEvaluator to automatically evaluate its text content as mathematical expressions and public its results with the registered callbacks.
open class AMInputTextView: UITextView, UITextViewDelegate {
    
    // MARK: Public Properties
    /// Whether the Lexers used by this textView will parse unit symbols.
    public var allowUnits = true
    /// The name of the variable that the text view assignes its results to. Currently variable evaluation is unsuable.
    public var variableName: String?
    
    /// Callback when text changes. This block is executed before the new text is evaluated.
    public var onTextChange: AMTextChangedHandler?
        
//    /// Callback when evaluation completes with result.
//    public var onResultUpdate: AMResultUpdateHandler?
    
    override open var text: String! {
        didSet {
            onTextChange?()
            textDidChange()
        }
    }
    
    // MARK: Private Properties
    
    /// Cache of current result.
    public var currentResult: AMValue?
    
    /// Evaluator backing this text view.
    private var interpreter: AMInterpreter!
    
    /// Weakly associated keyboard instance. This is required for the keyboard's exponent key to be updated on text replaced & selection changed.
    private weak var keyboard: AMKeyboardView!
    
    private weak var resultTextView: UITextView?
    private var resultFontSize: CGFloat?
        
    /// Helper function to update the state of the exponent key of the associated keyboard.
    public func updateIndentationKey() {
        keyboard.setIsIndenting(typingAttributes[.baselineOffset, default: 0.0] as! Double > 0.0)
    }
    
    /// Overrided to update exponent key of associated keyboard whenever selection changes.
    open override var selectedTextRange: UITextRange? {
        didSet {
            updateIndentationKey()
        }
    }
    
    // MARK: Basic Methods
    
    public init(frame: CGRect, keyboard: AMKeyboardView) {
        super.init(frame: frame, textContainer: nil)
        
        _init(keyboard)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Init from coder is not supported!")
    }
    
    /// Helper init function.
    private func _init(_ keyboardView: AMKeyboardView) {
        delegate = self
        autocorrectionType = .no
        autocapitalizationType = .none
        smartInsertDeleteType = .no
        keyboard = keyboardView
        interpreter = AMInterpreter()
        interpreter.delegate = self
        typingAttributes = [.font: normalFont]
        allowsEditingTextAttributes = true
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinched(_:))))
        if #available(iOS 11, *) {
            self.textDragInteraction?.isEnabled = false
        }
    }
    
    /// Only paste is allowed in menu.
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(paste(_:))
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        becomeFirstResponder()
    }
    
    // MARK: TextView Delegate
    public func textViewDidChange(_ textView: UITextView) {
        onTextChange?()
        textDidChange()
    }
    
    public func writeResult(to textView: UITextView, fontSize: CGFloat? = nil) {
        resultTextView = textView
        resultFontSize = fontSize
    }
    
    /// Performs the necessary updates & evaluations when text changes.
    func textDidChange() {
        typingAttributes.removeValue(forKey: .link)
        let lexer = AMLexer(textStorage: textStorage,
                            allowUnits: allowUnits,
                            variableName: variableName)
        let expression = lexer.lex()
        
        if let scrollView = superview as? UIScrollView {
            scrollView.layoutIfNeeded()
            scrollView.scrollRectToVisible(
                caretRect(for: selectedTextRange!.start),
                animated: false)
        }
        
        do {
            let result = try interpreter.evaluate(expression)
            currentResult = result
            result.descriptionFontSize = resultFontSize
            result.boundLabel = resultTextView
        }
        catch _{
            currentResult = nil
            guard let textView = resultTextView else {
                return
            }
            
            // blank-out label if it's empty input
            guard !text.isEmpty else {
                resultTextView?.attributedText = nil
                return
            }
            
            // else gray-out the displayed result
            textView.textStorage
                .addAttribute(.foregroundColor, value: UIColor.darkGray,
                              range: NSRange(location: 0, length: textView.textStorage.length))
        }
    }
    
    // MARK: Selector Functions
    @objc private func pinched(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            self.replace(textRange(from: beginningOfDocument, to: endOfDocument)!, withText: String())
            updateIndentationKey()
        }
    }

}

extension AMInputTextView {
    
    /// Process input key sent from the keyboard.
    func didReceive(key: AMKeyDescription) {
        
        switch key.style {
        case .operator where key.symbol == "^":
            selectionFeedback()
                        
            let newFont: UIFont
            let newBaseline: Double
            
            if typingAttributes[.baselineOffset, default: 0.0] as! Double == 0.0 {
                newFont = smallFont
                newBaseline = Double(scaled(20))
            }
            else {
                newFont = normalFont
                newBaseline = 0.0
            }
            
            textStorage.addAttributes([.font: newFont, .baselineOffset: newBaseline], range: selectedRange)
            typingAttributes[.baselineOffset] = newBaseline
            typingAttributes[.font] = newFont
            updateIndentationKey()
        case .delete:
            guard selectedTextRange!.end != beginningOfDocument else {
                return
            }
            
            if selectedTextRange!.isEmpty {
                // no selection, delete one character backwards (if exists)
                let startIndex = selectedTextRange!.start.index(in: self)
                replace(textRange(from: position(from: beginningOfDocument, offset: startIndex)!, to: selectedTextRange!.start)!, withText: "")
            }
            else {
                replace(selectedTextRange!, withText: "")
            }
            updateIndentationKey()
        case .function:
            if key.symbol == "×10^" {
                didReceive(key: .init(symbol: "×10", style: .constant))
                didReceive(key: .init(symbol: "^", style: .operator))
            }
            else {
                replace(selectedTextRange!, withText: key.symbol+"(")
            }
        case .solve: break
        default:
            replace(selectedTextRange!, withText: key.symbol)
            updateIndentationKey()
        }
    }
    
}

// MARK: AMInterpreterDelegate Conformance
extension AMInputTextView: AMInterpreterDelegate {
    
    public func interpreterDidReEvaluate(value: AMValue?, error: Error?) {
        currentResult = value
        value?.descriptionFontSize = resultFontSize
        value?.boundLabel = resultTextView
    }
    
}

// MARK: Helper Extension
extension UITextPosition {
    
    fileprivate func index(in textView: UITextView)-> Int {
        return textView.offset(from: textView.beginningOfDocument, to: self) - 1
    }
    
}

fileprivate let normalFont = UIFont(name: "Avenir Next", size: scaled(30))!
fileprivate let smallFont = normalFont.withSize(scaled(25))
