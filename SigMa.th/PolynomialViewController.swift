//
//  PolynomialViewController.swift
//  SigMa.th
//
//  Created by Chen Zerui on 29/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Keyboard

// MARK: Private Input-components
fileprivate let keyboard = SKeyboardView(size: CGSize(width: UIScreen.main.bounds.width,
                                                      height: UIScreen.main.bounds.height*0.6))

class PolynomialViewController: UIViewController {
    
    private let inputTextView = SInputTextView(frame: .zero, keyboard: keyboard)
    private lazy var inputContainerView = ContainerScrollView(wrapping: inputTextView)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInput()
    }
    
    private func setupInput() {
        inputTextView.leadingAnchor.constraint(greaterThanOrEqualTo: inputContainerView.leadingAnchor, constant: scaled(16)).isActive = true
        inputTextView.trailingAnchor
            .constraint(greaterThanOrEqualTo: inputContainerView.trailingAnchor, constant: scaled(-16)).isActive = true
        inputTextView.trailingAnchor
            .constraint(equalTo: inputContainerView.contentLayoutGuide.trailingAnchor).isActive = true
    }


}
