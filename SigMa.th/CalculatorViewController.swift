//
//  ViewController.swift
//  Numi
//
//  Created by Chen Zerui on 27/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine
import Keyboard
import Settings

// MARK: Private Input-components
fileprivate let keyboard = SKeyboardView(size: CGSize(width: UIScreen.main.bounds.width,
                                                       height: UIScreen.main.bounds.height*0.6))
fileprivate let unitSelector = SUnitSelectorView(keyboard: keyboard)

// MARK: MainViewController class
class CalculatorViewController: UIViewController {
    
    // MARK: Private Properties
    private let resultTextView = ResultTextView(frame: .zero)
    private lazy var resultScrollView = ContainerScrollView(wrapping: resultTextView)
    
    private let inputTextView = SInputTextView(frame: .zero, keyboard: keyboard)
    private lazy var inputScrollView = ContainerScrollView(wrapping: inputTextView)
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        keyboard.delegate = self
        setupProperties()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputTextView.becomeFirstResponder()
    }
    
    // MARK: Public Functions
    public override func becomeFirstResponder() -> Bool {
        inputTextView.becomeFirstResponder()
        return true
    }
    
    // MARK: Private Setups
    private func setupProperties() {
        
        // Result Text View
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        resultTextView.isOpaque = false
        resultTextView.backgroundColor = nil
        resultTextView.isScrollEnabled = false
        resultTextView.isEditable = false
        resultTextView.isSelectable = false
        resultTextView.menuContainerView = view
        
        // Result Scroll Container
        resultScrollView.translatesAutoresizingMaskIntoConstraints = false
        resultScrollView.bounces = false
        resultScrollView.showsVerticalScrollIndicator = false
        
        resultTextView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(resultLongPressed(_:))))
        
        // Input Text View
        inputTextView.backgroundColor = nil
        inputTextView.isScrollEnabled = false
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.inputView = keyboard
        inputTextView.inputAccessoryView = unitSelector
        inputTextView.textAlignment = .right
        
        // Input Scroll Container
        inputScrollView.translatesAutoresizingMaskIntoConstraints = false
        inputScrollView.bounces = false
        inputScrollView.showsVerticalScrollIndicator = false
        
        // setup result-update logic
        inputTextView.writeResult(to: resultTextView)
    }
    
    private func setupLayout() {
        
        // Main UI -> Result
        view.addSubview(resultScrollView)
        
        resultTextView.leadingAnchor
            .constraint(equalTo: resultScrollView.contentLayoutGuide.leadingAnchor, constant: scaled(16)).isActive = true
        resultTextView.trailingAnchor
            .constraint(lessThanOrEqualTo: resultScrollView.trailingAnchor, constant: scaled(-16)).isActive = true
        
        resultScrollView.topAnchor
            .constraint(equalTo: view.topAnchor, constant: scaled(62)).isActive = true
        resultScrollView.leadingAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        resultScrollView.trailingAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        resultScrollView.heightAnchor
            .constraint(greaterThanOrEqualToConstant: scaled(74)).isActive = true
        
        
        // Main UI -> Input
        view.addSubview(inputScrollView)
        
        inputTextView.leadingAnchor
            .constraint(greaterThanOrEqualTo: inputScrollView.leadingAnchor, constant: scaled(16)).isActive = true
        inputTextView.trailingAnchor
            .constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: scaled(-16)).isActive = true
        inputTextView.trailingAnchor
            .constraint(equalTo: inputScrollView.trailingAnchor).isActive = true
        
        inputScrollView.bottomAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:
                -keyboard.bounds.height - unitSelector.bounds.height - 8
            ).isActive = true
        inputScrollView.leadingAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        inputScrollView.trailingAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        inputScrollView.heightAnchor
            .constraint(greaterThanOrEqualToConstant: scaled(54)).isActive = true
    }
    
    // MARK: Selector Function
    @objc private func resultLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            UIPasteboard.general.string = resultTextView.textStorage.string
            BaseViewController.shared.displayMessage("Copied")
        }
    }

}

// MARK: SKeyboardViewDelegate Conformance
extension CalculatorViewController: SKeyboardViewDelegate {
    
    var textViewForInput: SInputTextView? {
        return inputTextView
    }
    
    var bottomInset: CGFloat {
        return view.safeAreaInsets.bottom
    }
    
    func didReceive(customKey symbol: String) {}
    
}
