//
//  SKeyboardContainerView.swift
//  NumCodeKeyboard
//
//  Created by Chen Zerui on 10/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine

public protocol SKeyboardViewDelegate: class {
    var textViewForInput: SInputTextView? {get}
    var bottomInset: CGFloat {get}
}

public class SKeyboardView: UIView {
    
    private let scrollView = UIScrollView(frame: .zero)
    let pages: [SKeyboardGridView]
    
    private var bottomConstraint: NSLayoutConstraint!
    
    public weak var delegate: SKeyboardViewDelegate?
    
    public init(size: CGSize) {
        
        let main = SKeyboardGridView(keys: mainKeys, columns: 4, size: size)
        let functions = SKeyboardGridView(keys: functionKeys, columns: 3, size: size)
        
        self.pages = [main, functions]
        
        super.init(frame: CGRect(origin: .zero, size: size))
        
        backgroundColor = .black
        
        scrollView.backgroundColor = nil
        scrollView.frame = main.bounds
        scrollView.contentSize = CGSize(width: size.width*2, height: size.height)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
                
        scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
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
    
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        bottomConstraint.constant = -(delegate?.bottomInset ?? 0)
        constraints.filter({$0.firstAttribute == .height}).forEach {
            $0.constant = self.scrollView.contentSize.height + (delegate?.bottomInset ?? 0) + CGFloat(10).scaled
        }
    }
    
    func setIsIndenting(_ flag: Bool) {
        let cell = pages[0].cellForItem(at: IndexPath(item: 18, section: 0)) as! SKeyViewNormal
        
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

extension SKeyboardView: UIInputViewAudioFeedback {
    
    func didPress(_ key: SKeyDescription) {
        delegate?.textViewForInput?.didReceive(key: key)
    }
    
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
    
}

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
                    .map(SKeyDescription.init)
fileprivate let functionKeys = zip(["Dl", "ln", "lg",
                                    "sin", "cos", "tan",
                                    "asin", "acos", "atan",
                                    "sqrt", "cbrt", "abs"],
                       [.delete, .function, .function,
                        .function, .function, .function,
                        .function, .function, .function,
                        .function, .function, .function])
                        .map(SKeyDescription.init)
