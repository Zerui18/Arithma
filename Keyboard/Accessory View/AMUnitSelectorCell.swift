//
//  AMUnitSelectorCell.swift
//  ArithmaKeyboard
//
//  Created by Chen Zerui on 12/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

/// UICollectionViewCell subclass which displays a unit, installed in AMUnitSelectorView.
class AMUnitSelectorCell: UICollectionViewCell {
    
    /// Label displaying the unit's name. Publicly accessible to allow direct setup from the collectionView datasource.
    lazy var label = UILabel(frame: bounds)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.textAlignment = .center
        label.font = unitLabelFont
        label.textColor = .white
        
        contentView.addSubview(label)
        layer.cornerRadius = scaled(10)
        backgroundColor = #colorLiteral(red: 0.1000000015, green: 0.1000000015, blue: 0.1000000015, alpha: 1)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showHighlighted() {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = #colorLiteral(red: 0.8376573464, green: 0.8459509835, blue: 0.8459509835, alpha: 1)
            self.label.textColor = #colorLiteral(red: 0.1000000015, green: 0.1000000015, blue: 0.1000000015, alpha: 1)
        }
    }
    
    func showNormal() {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = #colorLiteral(red: 0.1000000015, green: 0.1000000015, blue: 0.1000000015, alpha: 1)
            self.label.textColor = .white
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        showHighlighted()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        showNormal()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        showNormal()
    }
    
}

fileprivate let unitLabelFont = UIFont(name: "CourierNewPSMT", size: scaled(28))!
