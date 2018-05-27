//
//  SInputTextView.swift
//  NumCodeKeyboard
//
//  Created by Chen Zerui on 15/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine

public typealias SResultUpdateHandler = (SValue?, Error?) -> Void
public typealias STextChangedHandler = () -> Void

public class SInputTextView: UITextView {
    
    public var variableName: String?
    public var onTextChange: STextChangedHandler?
    public var onResultUpdate: SResultUpdateHandler?
    
    private var currentResult: SValue?
    private var interpreter: SInterpreter!
    private weak var keyboard: SKeyboardView!
    
    private func updateIndentationKey() {
        keyboard.setIsIndenting(typingAttributes[NSAttributedStringKey.baselineOffset.rawValue, default: 0.0] as! Double > 0.0)
    }
    
    public override var selectedTextRange: UITextRange? {
        didSet {
            updateIndentationKey()
        }
    }
    
    public init(frame: CGRect, keyboard: SKeyboardView) {
        super.init(frame: frame, textContainer: nil)
        
        _init(keyboard)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Init from coder is not supported!")
    }
    
    private func _init(_ keyboardView: SKeyboardView) {
        autocorrectionType = .no
        autocapitalizationType = .none
        keyboard = keyboardView
        interpreter = SInterpreter()
        interpreter.delegate = self
        typingAttributes = [NSAttributedStringKey.font.rawValue: normalFont]
        textContainer.lineBreakMode = .byWordWrapping
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(select(_:))
    }
    
    func textDidChange() {
        
        onTextChange?()
        
        let lexer = SLexer(textStorage: textStorage, variableName: variableName)
        let expression = lexer.lex()
        
        adjustContentSize()
        
        do {
            let result = try interpreter.evaluate(expression)
            currentResult = result
            onResultUpdate?(result, nil)
        }
        catch let error{
            currentResult = nil
            onResultUpdate?(nil, error)
        }
    }
    
    private func adjustContentSize() {
        let newSize = textStorage.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [], context: nil).size
        bounds.size = CGSize(width: bounds.width, height: max(bounds.height, newSize.height))
        contentSize = CGSize(width: newSize.width, height: newSize.height)
    }

}

fileprivate let selectionFeedBack = UISelectionFeedbackGenerator()
fileprivate let notificationFeedBack = UINotificationFeedbackGenerator()

extension SInputTextView {
    
    func didReceive(key: SKeyDescription) {
        
        defer {
            textDidChange()
        }
        
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
                attributesToSet = [.font: smallFont, .baselineOffset: Double(scaled(13.5))]
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
                let startIndex = selectedTextRange!.start.index(in: self)
                replace(textRange(from: position(from: beginningOfDocument, offset: startIndex)!, to: selectedTextRange!.start)!, withText: "")
            }
            else {
                replace(selectedTextRange!, withText: "")
            }
            updateIndentationKey()
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

extension SInputTextView: SInterpreterDelegate {
    
    public func interpreterDidReEvaluate(value: SValue?, error: Error?) {
        onResultUpdate?(value, error)
    }
    
}


extension UITextPosition {
    
    fileprivate func index(in textView: UITextView)-> Int {
        return textView.offset(from: textView.beginningOfDocument, to: self) - 1
    }
    
}

fileprivate let normalFont = UIFont(name: "CourierNewPSMT", size: scaled(40))!
fileprivate let smallFont = normalFont.withSize(scaled(30))

