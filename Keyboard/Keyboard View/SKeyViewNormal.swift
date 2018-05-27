//
//  SNormalKeyView.swift
//  NumCodeKeyboard
//
//  Created by Chen Zerui on 10/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

class SKeyViewNormal: UICollectionViewCell, SKeyboardKey{

    lazy var label = UILabel(frame: bounds)
    let innerRingLayer = CAShapeLayer()
    let outerRingLayer = CAShapeLayer()
    
    private var isBeingTouched = false
    private var isAnimating = false
    
    var keyDescription: SKeyDescription! {
        didSet {
            guard oldValue == nil else {
                fatalError("keyDescription can only be set once")
            }
            
            label.text = keyDescription.symbol
            label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            label.font = keyDescription.style == .function ? smallerKeyFont:keyFont
            label.textAlignment = .center
            
            innerRingLayer.borderColor = keyDescription.style.highlightedCircleColor.cgColor
            outerRingLayer.borderColor = innerRingLayer.borderColor
            
            contentView.addSubview(label)
            
            setupRings()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = nil
    }
    
    private func setupRings() {
        let factor: CGFloat = keyDescription.style == .function ? 4:2
        
        let innerDiameter = bounds.height * 0.75
        let origin = (bounds.height-innerDiameter) / 2
        innerRingLayer.frame = CGRect(x: origin, y: origin, width: innerDiameter, height: innerDiameter)
        innerRingLayer.cornerRadius = innerDiameter / factor
        
        let outerDiameter = bounds.height * 0.9
        let origin2 = (bounds.height-outerDiameter) / 2
        outerRingLayer.frame = CGRect(x: origin2, y: origin2, width: outerDiameter, height: outerDiameter)
        outerRingLayer.cornerRadius = outerDiameter / factor
        
        layer.addSublayer(innerRingLayer)
        layer.addSublayer(outerRingLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isBeingTouched = true
        animateSelection()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isBeingTouched = false
        
        if keyDescription.symbol != "^" {
            animateDeselection()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isBeingTouched = false
        
        if keyDescription.symbol != "^" {
            animateDeselection()
        }
    }
    
    func animateSelection() {
        
        if self.keyDescription.symbol == "^" && innerRingLayer.borderWidth != 0 {
            isAnimating = false
            animateDeselection()
            return
        }
        
        if !isAnimating {
            CATransaction.flush()
        }
        
        isAnimating = true
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
        CATransaction.setCompletionBlock {
            self.isAnimating = false
            if !self.isBeingTouched && self.keyDescription.symbol != "^" {
                self.animateDeselection()
            }
        }
        
        innerRingLayer.borderWidth = scaled(2)
        outerRingLayer.borderWidth = scaled(3.5)
        label.textColor = keyDescription.style.highlightedTextColor
        
        CATransaction.commit()
    }
    
    func animateDeselection(force: Bool = false) {

        guard !isAnimating || force else {
            return
        }
        
        if force {
            CATransaction.flush()
        }
        isAnimating = true
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        CATransaction.setCompletionBlock {
            self.isAnimating = false
        }
        
        innerRingLayer.borderWidth = 0
        outerRingLayer.borderWidth = 0
        label.textColor = .white
        
        CATransaction.commit()
    }
    
}

fileprivate let keyFont = UIFont(name: "CourierNewPSMT", size: scaled(46))!
fileprivate let smallerKeyFont = UIFont(name: "CourierNewPSMT", size: scaled(30))!
