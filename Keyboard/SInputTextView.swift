//
//  SInputTextView.swift
//  NumCodeKeyboard
//
//  Created by Chen Zerui on 15/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine

// MARK: Callback Types
public typealias SResultUpdateHandler = (SValue?, Error?) -> Void
public typealias STextChangedHandler = () -> Void
public typealias SEmptyBackspaceHandler = ()-> Void

// MARK: SInputTextView
/// Custom UITextView subclass which integrates with SEvaluator to automatically evaluate its text content as mathematical expressions and public its results with the registered callbacks.
open class SInputTextView: UITextView, UITextViewDelegate {
    
    // MARK: Public Properties
    /// The name of the variable that the text view assignes its results to. Currently variable evaluation is unsuable.
    public var variableName: String?
    
    /// Callback when text changes. This block is executed before the new text is evaluated.
    public var onTextChange: STextChangedHandler?
        
//    /// Callback when evaluation completes with result.
//    public var onResultUpdate: SResultUpdateHandler?
    
    override open var text: String! {
        didSet {
            onTextChange?()
            textDidChange()
        }
    }
    
    // MARK: Private Properties
    
    /// Cache of current result.
    public var currentResult: SValue?
    
    /// Evaluator backing this text view.
    private var interpreter: SInterpreter!
    
    /// Weakly associated keyboard instance. This is required for the keyboard's exponent key to be updated on text replaced & selection changed.
    private weak var keyboard: SKeyboardView!
    
    private weak var resultTextView: UITextView?
    private var resultFontSize: CGFloat?
        
    /// Helper function to update the state of the exponent key of the associated keyboard.
    public func updateIndentationKey() {
        keyboard.setIsIndenting(typingAttributes[NSAttributedStringKey.baselineOffset.rawValue, default: 0.0] as! Double > 0.0)
    }
    
    /// Overrided to update exponent key of associated keyboard whenever selection changes.
    open override var selectedTextRange: UITextRange? {
        didSet {
            updateIndentationKey()
        }
    }
    
    // MARK: Basic Methods
    
    public init(frame: CGRect, keyboard: SKeyboardView) {
        super.init(frame: frame, textContainer: nil)
        
        _init(keyboard)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Init from coder is not supported!")
    }
    
    /// Helper init function.
    private func _init(_ keyboardView: SKeyboardView) {
        delegate = self
        autocorrectionType = .no
        autocapitalizationType = .none
        keyboard = keyboardView
        interpreter = SInterpreter()
        interpreter.delegate = self
        typingAttributes = [NSAttributedStringKey.font.rawValue: normalFont]
        textContainer.lineBreakMode = .byWordWrapping
    }
    
    /// Only selectAll is allowed in menu.
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(selectAll(_:)) || action == #selector(paste(_:))
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
        
        let lexer = SLexer(textStorage: textStorage, variableName: variableName)
        let expression = lexer.lex()
        
        do {
            let result = try interpreter.evaluate(expression)
            currentResult = result
            result.fontSize = resultFontSize
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

}

fileprivate let selectionFeedBack = UISelectionFeedbackGenerator()
fileprivate let notificationFeedBack = UINotificationFeedbackGenerator()

extension SInputTextView {
    
    /// Process input key sent from the keyboard.
    func didReceive(key: SKeyDescription) {
        
        switch key.style {
        case .operator where key.symbol == "^":
            
            guard selectedTextRange!.end != beginningOfDocument else {
                notificationFeedBack.notificationOccurred(.warning)
                let cell = keyboard!.pages[0].cellForItem(at: IndexPath(item: 18, section: 0)) as! SKeyViewNormal
                cell.animateDeselection(force: true)
                return
            }

            selectionFeedBack.selectionChanged()
            let attributesToSet: [NSAttributedStringKey: Any]
            
            if typingAttributes[NSAttributedStringKey.baselineOffset.rawValue, default: 0.0] as! Double == 0.0 {
                attributesToSet = [.font: smallFont, .baselineOffset: Double(scaled(26))]
            }
            else {
                attributesToSet = [.font: normalFont, .baselineOffset: 0.0]
            }
            
            textStorage.addAttributes(attributesToSet, range: selectedRange)
            typingAttributes = Dictionary(uniqueKeysWithValues: attributesToSet.map{($0.rawValue, $1)})
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
        case .solve: break
        default:
            
            if key.style == .function {
                replace(selectedTextRange!, withText: key.symbol+"(")
            }
            else {
                replace(selectedTextRange!, withText: key.symbol)
            }
            updateIndentationKey()
        }
    }
    
}

// MARK: SInterpreterDelegate Conformance
extension SInputTextView: SInterpreterDelegate {
    
    public func interpreterDidReEvaluate(value: SValue?, error: Error?) {}
    
}

// MARK: Helper Extension
extension UITextPosition {
    
    fileprivate func index(in textView: UITextView)-> Int {
        return textView.offset(from: textView.beginningOfDocument, to: self) - 1
    }
    
}

fileprivate let normalFont = UIFont(name: "CourierNewPSMT", size: scaled(52))!
fileprivate let smallFont = normalFont.withSize(scaled(39))

