//
//  ResultTextView.swift
//  SigMa.th
//
//  Created by Chen Zerui on 27/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

class ResultTextView: UITextView {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

}
