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
    
    static weak var currentActive: PolynomialCell?
    
    var degree: UInt! {
        didSet {
            topLabel.string = degree.description
        }
    }
    lazy var linkedInputView = SInputTextView(frame: .zero, keyboard: keyboardView)
    
    private let topLabel = CATextLayer()
    private let bLabel = UITextView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        topLabel.foregroundColor = UIColor.white.cgColor
        topLabel.frame = CGRect(origin: .zero, size:
            CGSize(width: frame.width, height: frame.height*0.3)
        )
        topLabel.fontSize = 26
        contentView.layer.addSublayer(topLabel)
        
        linkedInputView.backgroundColor = nil
        linkedInputView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: scaled(54))
        linkedInputView.inputView = keyboardView
        linkedInputView.inputAccessoryView = linkedInputView
        linkedInputView.writeResult(to: bLabel, fontSize: 26)
        
        bLabel.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        bLabel.textColor = .black
        bLabel.frame = CGRect(x: 0, y: frame.height*0.3,
                              width: frame.width, height: frame.height*0.7)
        bLabel.isEditable = false
        bLabel.inputView = keyboardView
        bLabel.inputAccessoryView = linkedInputView
        bLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(beginEditing)))
        contentView.addSubview(bLabel)
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
