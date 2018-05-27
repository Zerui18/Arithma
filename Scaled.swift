//
//  Double+Scaled.swift
//  NumCodeBackend
//
//  Created by Chen Zerui on 20/4/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

fileprivate let scale = min(UIScreen.main.bounds.width/375, UIScreen.main.bounds.height/812)

public func scaled(_ v: CGFloat)-> CGFloat {
    return v * scale
}
