//
//  TrigoToggleButton.swift
//  NumCode
//
//  Created by Chen Zerui on 31/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Settings

// MARK: TrigoToggleButton class
class ToggleButton: UIButton {
    
    // MARK: Private Properties
    private var darkenTimer: Timer?
    private let borderLayer = CALayer()
    private let colors: (UIColor, UIColor)
    private let labels: (String, String)
    private let propertyPath: ReferenceWritableKeyPath<SSettings, Bool>
    
    // MARK: Methods
    init(colors: (UIColor, UIColor), labels: (String, String), propertyPath: ReferenceWritableKeyPath<SSettings, Bool>) {
        
        self.colors = colors
        self.labels = labels
        self.propertyPath = propertyPath
        
        super.init(frame: .zero)
        alpha = 0.65
        borderLayer.frame = layer.bounds
        borderLayer.cornerRadius = 8
        borderLayer.borderWidth = 2
        borderLayer.borderColor = getTintColor().cgColor
        layer.addSublayer(borderLayer)
        
        titleLabel?.font = UIFont.systemFont(ofSize: 28)
        setTitle(getTitle(), for: UIControlState())
        setTitleColor(getTintColor(), for: UIControlState())
        
        addTarget(self, action: #selector(buttonToggled), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        borderLayer.frame = layer.bounds
    }
    
    @objc private func buttonToggled() {
        darkenTimer?.invalidate()
    
        SSettings.shared[keyPath: propertyPath].toggle()
        
        CATransaction.flush()
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        borderLayer.borderColor = getTintColor().cgColor
        CATransaction.commit()
        
        alpha = 1
        titleLabel!.alpha = 1
        
        UIView.animate(withDuration: 0.15, animations: {
            self.titleLabel!.alpha = 0
        }) {_ in
            self.setTitle(self.getTitle(), for: UIControlState())
            self.setTitleColor(self.getTintColor(), for: UIControlState())
            
            UIView.animate(withDuration: 0.15) {
                self.titleLabel!.alpha = 1
            }
        }
        
        darkenTimer = Timer.scheduledTimer(withTimeInterval: 0.3+2, repeats: false) {_ in
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0.65
            }
        }
    }
    
    // Private functions
    private func getTintColor()-> UIColor {
        return SSettings.shared[keyPath: propertyPath] ? colors.0:colors.1
    }
    
    private func getTitle()-> String {
        return SSettings.shared[keyPath: propertyPath] ? labels.0:labels.1
    }

}
