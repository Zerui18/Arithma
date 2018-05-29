//
//  UILabel+Extension.swift
//  SigMa.th
//
//  Created by Chen Zerui on 29/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

extension UILabel {
    
    func animateText(to newText: String) {
        self.text = newText
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
}
