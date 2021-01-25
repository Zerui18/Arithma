//
//  ResultTextView.swift
//  SigMa.th
//
//  Created by Chen Zerui on 27/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

class ResultTextView: UITextView {

    /// View where the MenuController will be embeded in, must be a superView of this instance.
    var menuContainerView: UIView!
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        layer.cornerRadius = scaled(10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        layer.backgroundColor = #colorLiteral(red: 0.1000000015, green: 0.1000000015, blue: 0.1000000015, alpha: 1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        layer.backgroundColor = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        layer.backgroundColor = nil
    }
    
}
