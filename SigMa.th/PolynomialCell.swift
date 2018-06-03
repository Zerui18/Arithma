//
//  PolynomialCell.swift
//  SigMa.th
//
//  Created by Chen Zerui on 30/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Keyboard

class PolynomialCell: UICollectionViewCell {
    
    private class TextView: UITextView {
        fileprivate weak var cell: PolynomialCell!
        
        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            return false
        }
        override func becomeFirstResponder() -> Bool {
            defer{ cell.linkedInputView.becomeFirstResponder() }
            return super.becomeFirstResponder()
        }
    }
    
    /// Currently active PolynomialCell instance.
    static weak var currentActive: PolynomialCell?
    
    /// UInt representing the degree this cell represents.
    var degree: UInt! {
        didSet {
            let label = NSMutableAttributedString(string: "x", attributes: [.font: baseFont, .foregroundColor: UIColor.white])
            label.append(NSAttributedString(string: degree.description, attributes: [.font: expoFont, .baselineOffset: 13.0]))
            degreeLabel.attributedText = label
        }
    }
    
    /// Input textfield serving as inputAccesoryView for the coefficientLabel.
    lazy var linkedInputView = SInputTextView(frame: .zero, keyboard: keyboardView)
    
    private let degreeLabel = UILabel(frame: .zero)
    private let coefficientLabel = TextView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.masksToBounds = false
        contentView.layer.masksToBounds = false
        
        linkedInputView.backgroundColor = nil
        linkedInputView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: scaled(54))
        linkedInputView.inputView = keyboardView
        linkedInputView.inputAccessoryView = linkedInputView
        linkedInputView.writeResult(to: coefficientLabel, fontSize: 26)
        
        coefficientLabel.cell = self
        coefficientLabel.layer.cornerRadius = scaled(10)
        coefficientLabel.backgroundColor = #colorLiteral(red: 0.1470725536, green: 0.1470725536, blue: 0.1470725536, alpha: 1)
        coefficientLabel.textColor = .black
        coefficientLabel.frame = CGRect(origin: .zero,
                                        size: CGSize(width: frame.width*0.7, height: frame.height))
        coefficientLabel.isEditable = false
        coefficientLabel.inputView = keyboardView
        coefficientLabel.inputAccessoryView = linkedInputView
        coefficientLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(beginEditing))
        )
        contentView.addSubview(coefficientLabel)
        
        degreeLabel.textColor = .white
        degreeLabel.frame = CGRect(x: frame.width*0.75, y: 0,
                                   width: frame.width*0.2, height: frame.height)
        contentView.addSubview(degreeLabel)
        
        linkedInputView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func beginEditing() {
        linkedInputView.becomeFirstResponder()
        linkedInputView.updateIndentationKey()
        PolynomialCell.currentActive = self
    }
}


fileprivate let baseFont = UIFont(name: "CourierNewPSMT", size: 26)!
fileprivate let expoFont = UIFont(name: "CourierNewPSMT", size: 19.5)!
