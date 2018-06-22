//
//  UITextView+Patch.swift
//  Arithma
//
//  Created by Chen Zerui on 22/6/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

extension UITextView {
    
    static func patch() {
        let original = class_getInstanceMethod(UITextView.self, #selector(UITextView.init(frame:textContainer:)))!
        let new = class_getInstanceMethod(UITextView.self, #selector(swizzled_init(frame:textContainer:)))!
        method_exchangeImplementations(original, new)
    }
    
    @objc private func swizzled_init(frame: CGRect, textContainer: NSTextContainer?)-> UITextView {
        let instance = swizzled_init(frame: frame, textContainer: textContainer)
        instance.inputAssistantItem.leadingBarButtonGroups = []
        instance.inputAssistantItem.trailingBarButtonGroups = []
        return instance
    }
    
}
