//
//  SafeArea.swift
//  Arithma
//
//  Created by Chen Zerui on 22/6/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

extension UIView {
    
    var topSAAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    var bottomSAAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
    
}
