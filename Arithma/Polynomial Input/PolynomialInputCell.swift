//
//  PolynomialCell.swift
//  SigMa.th
//
//  Created by Chen Zerui on 30/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Keyboard


class PolynomialInputCell: UIView {

    private class TextView: UITextView {

        fileprivate weak var cell: PolynomialInputCell!

        override public init(frame: CGRect, textContainer: NSTextContainer?) {
            super.init(frame: frame, textContainer: textContainer)
            layer.borderColor = UIColor.lightGray.cgColor
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            return false
        }

        func animateSelect() {
            layer.borderWidth = 2
        }

        func animateDeselect() {
            layer.borderWidth = 0
        }
        
        override var attributedText: NSAttributedString! {
            get {
                return super.attributedText
            }
            set {
                super.attributedText = newValue
            }
        }

    }

    /// Currently active PolynomialCell instance.
    static weak var currentActive: PolynomialInputCell? {
        didSet(lastActive){
            if currentActive != lastActive {
                lastActive?.coefficientLabel.animateDeselect()
                currentActive?.coefficientLabel.animateSelect()
            }
        }
    }

    /// UInt representing the degree this cell represents.
    var degree: UInt! {
        didSet {
            let label = NSMutableAttributedString(string: "x",
                                                  attributes: [.font: baseFont, .foregroundColor: UIColor.white])
            label.append(NSAttributedString(string: degree.description,
                                            attributes: [.font: expoFont, .baselineOffset: scaled(17), .foregroundColor: UIColor.white]))
            degreeLabel.attributedText = label
        }
    }

    /// Input textfield serving as inputAccesoryView for the coefficientLabel.
    let linkedInputView = AMInputTextView(frame: .zero, keyboard: keyboardView)
    private lazy var inputScrollView = ContainerScrollView(wrapping: linkedInputView)
    
    private let coefficientLabel = TextView(frame: .zero)
    private let degreeLabel = UITextView(frame: .zero)

    /*
     How the keyboard works:
     linkedInputView.inputView -> keyboard
     coefficientLabel acts as button to relay linkedInputView.becomeFirstResponder()
     */

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperties()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupProperties() {
        
        linkedInputView.allowUnits = false
        linkedInputView.translatesAutoresizingMaskIntoConstraints = false
        linkedInputView.backgroundColor = #colorLiteral(red: 0.1000000015, green: 0.1000000015, blue: 0.1000000015, alpha: 1)
        linkedInputView.inputView = PolynomialInputCell.keyboardView
        linkedInputView.isScrollEnabled = false
        linkedInputView.layer.borderColor = UIColor.lightGray.cgColor
        linkedInputView.layer.borderWidth = 3
        linkedInputView.layer.cornerRadius = scaled(14)
        linkedInputView.tintColor = .lightGray
        linkedInputView.textAlignment = .right
        linkedInputView.writeResult(to: coefficientLabel, fontSize: scaled(34))
        
        coefficientLabel.textContainer.lineFragmentPadding = 0

        inputScrollView.translatesAutoresizingMaskIntoConstraints = false
        inputScrollView.tag = -999

        coefficientLabel.translatesAutoresizingMaskIntoConstraints = false
        coefficientLabel.layer.cornerRadius = scaled(10)
        coefficientLabel.backgroundColor = #colorLiteral(red: 0.1000000015, green: 0.1000000015, blue: 0.1000000015, alpha: 1)
        coefficientLabel.textColor = .black
        coefficientLabel.cell = self

        // prevent interference
        coefficientLabel.isEditable = false
        coefficientLabel.isScrollEnabled = false
        coefficientLabel.gestureRecognizers!
            .forEach(coefficientLabel.removeGestureRecognizer)
        coefficientLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(beginEditing(_:)))
        )

        degreeLabel.isOpaque = false
        degreeLabel.isUserInteractionEnabled = false
        degreeLabel.backgroundColor = nil
        degreeLabel.translatesAutoresizingMaskIntoConstraints = false
        degreeLabel.isScrollEnabled = false
    }

    private func setupLayout() {
        linkedInputView.leadingAnchor
            .constraint(greaterThanOrEqualTo: inputScrollView.leadingAnchor,
                        constant: scaled(16)).isActive = true
        linkedInputView.trailingAnchor
            .constraint(equalTo: inputScrollView.trailingAnchor).isActive = true
        linkedInputView.widthAnchor
            .constraint(greaterThanOrEqualToConstant: scaled(200)).isActive = true
        
        addSubview(coefficientLabel)
        coefficientLabel.leadingAnchor
            .constraint(equalTo: leadingAnchor, constant: scaled(4)).isActive = true
        coefficientLabel.topAnchor
            .constraint(equalTo: topAnchor).isActive = true
        coefficientLabel.bottomAnchor
            .constraint(equalTo: bottomAnchor).isActive = true
        coefficientLabel.widthAnchor
            .constraint(greaterThanOrEqualToConstant: scaled(120)).isActive = true
        coefficientLabel.heightAnchor
            .constraint(greaterThanOrEqualToConstant: scaled(50)).isActive = true

        addSubview(degreeLabel)
        degreeLabel.leadingAnchor
            .constraint(equalTo: coefficientLabel.trailingAnchor,
                        constant: scaled(8)).isActive = true
        degreeLabel.centerYAnchor
            .constraint(equalTo: centerYAnchor, constant: scaled(-4)).isActive = true
        degreeLabel.trailingAnchor
            .constraint(equalTo: trailingAnchor).isActive = true
        degreeLabel.heightAnchor
            .constraint(greaterThanOrEqualToConstant: scaled(50)).isActive = true
    }

    @objc func beginEditing(_ sender: Any?) {
        if sender != nil {
            UISelectionFeedbackGenerator().selectionChanged()
        }
        PolynomialInputCell.currentActive = self
        PolynomialViewController.shared.presentInputView(linkedInputView)
    }
}


fileprivate let baseFont = UIFont(name: "CourierNewPSMT", size: scaled(34))!
fileprivate let expoFont = UIFont(name: "CourierNewPSMT", size: scaled(25.5))!
