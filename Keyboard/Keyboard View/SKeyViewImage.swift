//
//  SDeleteKeyView.swift
//  NumCodeKeyboard
//
//  Created by Chen Zerui on 20/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

class SKeyViewImage: UICollectionViewCell, SKeyboardKey{
    
    var keyDescription: SKeyDescription! {
        didSet {
            guard oldValue == nil else {
                fatalError("keyDescription can only be set once")
            }
            
            let imageName: String = "ic_key_delete"
            
            imageView.image = UIImage(named: imageName,
                                      in: Bundle(for: SKeyViewImage.self),
                                      compatibleWith: nil)!
            
            backgroundColor = nil
            imageView.tintColor = .white
            imageView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(imageView)
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: scaled(55)).isActive = true
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            
            setupRings()
        }
    }
    
    lazy private var imageView = UIImageView(frame: bounds)
    let innerRingLayer = CAShapeLayer()
    let outerRingLayer = CAShapeLayer()
    
    private var isBeingTouched = false
    private var isAnimating = false
    
    private func setupRings() {
        let factor: CGFloat = 2
        
        let innerDiameter = bounds.height * 0.75
        let origin = (bounds.height-innerDiameter) / 2
        innerRingLayer.frame = CGRect(x: origin, y: origin, width: innerDiameter, height: innerDiameter)
        innerRingLayer.cornerRadius = innerDiameter / factor
        innerRingLayer.borderColor = keyDescription.style.highlightedCircleColor.cgColor
        
        let outerDiameter = bounds.height * 0.9
        let origin2 = (bounds.height-outerDiameter) / 2
        outerRingLayer.frame = CGRect(x: origin2, y: origin2, width: outerDiameter, height: outerDiameter)
        outerRingLayer.cornerRadius = outerDiameter / factor
        outerRingLayer.borderColor = keyDescription.style.highlightedCircleColor.cgColor
        
        
        layer.addSublayer(innerRingLayer)
        layer.addSublayer(outerRingLayer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isBeingTouched = true
        animateSelection()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isBeingTouched = false
        animateDeselection()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isBeingTouched = false
        animateDeselection()
    }
    
    func animateSelection() {

        isAnimating = true
        UIView.animate(withDuration: 0.2, animations: {
            self.imageView.tintColor = self.keyDescription.style.highlightedTextColor
        }) { _ in
            self.isAnimating = false
            
            if !self.isBeingTouched {
                self.animateDeselection()
            }
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
        
        innerRingLayer.borderWidth = scaled(2)
        outerRingLayer.borderWidth = scaled(3.5)
        
        CATransaction.commit()
    }
    
    func animateDeselection() {
        
        if isAnimating {return}
        isAnimating = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.imageView.tintColor = .white
        }) { _ in
            self.isAnimating = false
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        
        innerRingLayer.borderWidth = 0
        outerRingLayer.borderWidth = 0
        
        CATransaction.commit()
    }
}
