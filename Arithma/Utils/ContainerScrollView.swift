//
//  ContainerScrollView.swift
//  Arithma
//
//  Created by Chen Zerui on 3/4/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

/// Container scrollview that tightly wraps around the childView, imitating it's height and thus scrolling horizontally.
class ContainerScrollView: UIScrollView {

    
    // MARK: Init
    convenience init(wrapping childView: UIView) {
        self.init(frame: .zero)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(childView)
        childView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        childView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        heightAnchor.constraint(equalTo: childView.heightAnchor).isActive = true
        childView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
    }
    
}
