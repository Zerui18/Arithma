//
//  AMKeyboardView.swift
//  ArithmaKeyboard
//
//  Created by Chen Zerui on 10/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine

public protocol AMKeyboardViewDelegate: class {
    var textViewForInput: AMInputTextView? {get}
    var bottomInset: CGFloat {get}
    
    func didReceive(customKey symbol: String)
}

/// Embeds a paging UIScrollView which contains the keyboard grids.
public class AMKeyboardView: UIView {
    
    let pages: [AMKeyboardGridView]
    
    /// Scroll view which encapsulates the key grids.
    private let scrollView = UIScrollView(frame: .zero)
    /// Constraint of scrollView to the bottom of self. The constraint's constant is maintained to avoid bottom safeAreaInsets.
    private weak var bottomConstraint: NSLayoutConstraint!
    
    public weak var delegate: AMKeyboardViewDelegate?
    
    public init(size: CGSize, useImaginary: Bool = true) {
        
        let main: AMKeyboardGridView
        let functions = AMKeyboardGridView(keys: functionKeys, columns: 3, size: size)
        let extras = AMKeyboardGridView(keys: extraKeys, columns: 3, size: size)
        
        if useImaginary {
            main = AMKeyboardGridView(keys: mainKeys, columns: 4, size: size)
        }
        else {
            var newGrid = mainKeys
            newGrid[newGrid.count-1] = AMKeyDescription(symbol: "=", style: .solve)
            main = AMKeyboardGridView(keys: newGrid, columns: 4, size: size)
        }
        
        self.pages = [extras, main, functions]
        
        super.init(frame: CGRect(origin: .zero, size: size))
        
        backgroundColor = .black
        
        scrollView.backgroundColor = nil
        scrollView.frame = main.bounds
        scrollView.contentSize = CGSize(width: size.width*3, height: size.height)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint.isActive = true
        
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        pages.enumerated().forEach {
            $1.keyboard = self
            $1.frame.origin = CGPoint(x: CGFloat($0) * $1.bounds.width, y: 0)
            $1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.scrollView.addSubview($1)
        }
        
        // scroll to main keys
        scrollView.contentOffset = CGPoint(x: size.width, y: 0)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Hacks to fix layout issue with bottom safe-area insets on iPhone X.
    public override func didMoveToWindow() {
        bottomConstraint.constant = -(delegate?.bottomInset ?? 0)
        constraints.filter({$0.firstAttribute == .height}).forEach {
            $0.constant = self.scrollView.contentSize.height + (delegate?.bottomInset ?? 0) + scaled(10)
        }
    }
    
    /// Update the exponent key's appearance. Only call this on the "main" keyboard.
    func setIsIndenting(_ flag: Bool) {
        guard let cell = pages[1].cellForItem(at: IndexPath(item: 18, section: 0)) as? AMKeyViewNormal
            else {return}
        
        if flag {
            if cell.innerRingLayer.borderWidth == 0 {
                cell.animateSelection()
            }
        }
        else {
            if cell.innerRingLayer.borderWidth > 0 {
                cell.animateDeselection()
            }
        }
    }

}

// MARK: On Key Click
extension AMKeyboardView: UIInputViewAudioFeedback {
    
    func didPress(_ key: AMKeyDescription) {
        if key.style == .solve {
            delegate?.didReceive(customKey: "=")
        }
        else {
            delegate?.textViewForInput?.didReceive(key: key)
        }
    }
    
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
    
}

// MARK: Key Arrangements
fileprivate let extraKeys = zip(["Dl", "sqrt", "cbrt",
                                 "abs", "floor", "ceil",
                                 "sinh", "cosh", "tanh",
                                 "asinh", "acosh", "atanh"],
                                [.delete, .function, .function,
                                 .function, .function, .function,
                                 .function, .function, .function,
                                 .function, .function, .function])
                                .map(AMKeyDescription.init)
fileprivate let mainKeys = zip(["Dl", "(", ")", "+",
                                "7", "8", "9", "-",
                                "4", "5", "6", "×",
                                "1", "2", "3", "÷",
                                "0", ".", "^", "i"],
                   [.delete, .operator, .operator, .operator,
                    .number, .number, .number, .operator,
                    .number, .number, .number, .operator,
                    .number, .number, .number, .operator,
                    .number, .number, .operator, .operator])
                    .map(AMKeyDescription.init)
fileprivate let functionKeys = zip(["Dl", "℮", "π",
                                    "exp", "ln", "lg",
                                    "sin", "cos", "tan",
                                    "asin", "acos", "atan"],
                       [.delete, .constant, .constant,
                        .function, .function, .function,
                        .function, .function, .function,
                        .function, .function, .function])
                        .map(AMKeyDescription.init)
