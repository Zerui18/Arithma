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

//Private Input-components
fileprivate let keyboard = SKeyboardView(size: CGSize(width: UIScreen.main.bounds.width,
                                                       height: UIScreen.main.bounds.height*0.6))
fileprivate let unitSelector = SUnitSelectorView(keyboard: keyboard)

// MARK: MainViewController class
class MainViewController: UIViewController {
    
    
    static let shared = MainViewController()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Private Properties
    private let trigoModeButton = ToggleButton(colors: (#colorLiteral(red: 0.7163728282, green: 0.9372549057, blue: 0.8692806858, alpha: 1), #colorLiteral(red: 0.4371609821, green: 0.5123683887, blue: 0.9686274529, alpha: 1)), labels: ("D", "R"), propertyPath: \SSettings.isDegreeMode)
    private let scientificModeButton = ToggleButton(colors: (#colorLiteral(red: 0.5568627715, green: 0.4501634074, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)), labels: ("S", "N"), propertyPath: \SSettings.isScientificMode)
    
    private let resultTextView = UITextView(frame: .zero)
    private lazy var resultScrollView = ContainerScrollView(wrapping: resultTextView)
    
    private let inputTextView = SInputTextView(frame: .zero, keyboard: keyboard)
    private lazy var inputScrollView = ContainerScrollView(wrapping: inputTextView)
    
    // MARK: View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        keyboard.delegate = self
        
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyAnimations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputTextView.becomeFirstResponder()
    }
    
    // MARK: Private Methods
    private func setupLayout() {
        
        // Toggle Buttons
        
        scientificModeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scientificModeButton)
        scientificModeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: scaled(16)).isActive = true
        scientificModeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: scaled(16)).isActive = true
        scientificModeButton.widthAnchor.constraint(equalToConstant: scaled(36)).isActive = true
        scientificModeButton.heightAnchor.constraint(equalToConstant: scaled(36)).isActive = true
        
        
        trigoModeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(trigoModeButton)
        trigoModeButton.topAnchor.constraint(equalTo: scientificModeButton.topAnchor).isActive = true
        trigoModeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: scaled(-16)).isActive = true
        trigoModeButton.widthAnchor.constraint(equalToConstant: scaled(36)).isActive = true
        trigoModeButton.heightAnchor.constraint(equalToConstant: scaled(36)).isActive = true
        
        // Main UI -> Result
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        resultTextView.isOpaque = false
        resultTextView.backgroundColor = nil
        resultTextView.isScrollEnabled = false
        resultTextView.isEditable = false
        resultTextView.isSelectable = false
        
        resultTextView.leadingAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.leadingAnchor, constant: 16).isActive = true
        resultTextView.trailingAnchor.constraint(lessThanOrEqualTo: resultScrollView.trailingAnchor, constant: -16).isActive = true
        
        resultScrollView.translatesAutoresizingMaskIntoConstraints = false
        resultScrollView.bounces = false
        resultScrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(resultScrollView)
        resultScrollView.topAnchor.constraint(equalTo: trigoModeButton.bottomAnchor, constant: scaled(24)).isActive = true
        resultScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        resultScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        resultScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: scaled(74)).isActive = true
        
        
        // Main UI -> Input
        inputTextView.backgroundColor = nil
        inputTextView.isScrollEnabled = false
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.inputView = keyboard
        inputTextView.inputAccessoryView = unitSelector
        inputTextView.textAlignment = .right
        
//        inputTextView.transform = CGAffineTransform(rotationAngle: .pi)
        
//        inputScrollView.contentMode = .right
        inputScrollView.translatesAutoresizingMaskIntoConstraints = false
        inputScrollView.bounces = false
        inputScrollView.showsVerticalScrollIndicator = false
//        inputScrollView.transform = CGAffineTransform(rotationAngle: .pi)
        
        view.addSubview(inputScrollView)
        inputScrollView.topAnchor.constraint(equalTo: resultScrollView.bottomAnchor, constant: scaled(16)).isActive = true
        inputScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        inputScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        inputScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: scaled(54)).isActive = true
        
        inputTextView.leadingAnchor.constraint(greaterThanOrEqualTo: inputScrollView.leadingAnchor, constant: 16).isActive = true
        inputTextView.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: -16).isActive = true
        inputTextView.trailingAnchor.constraint(equalTo: inputScrollView.trailingAnchor).isActive = true
        
        // setup result-update logic
        inputTextView.onResultUpdate = { value, error in
            guard error == nil else {
                
                // blank-out label if it's empty input
                guard !self.inputTextView.text.isEmpty else {
                    self.resultTextView.text = nil
                    return
                }
                
                // else gray-out the displayed result
                self.resultTextView.textStorage.addAttribute(.foregroundColor, value: UIColor.darkGray, range: NSRange(location: 0, length: self.resultTextView.textStorage.length))
                return
            }
            
            // no error
            value!.boundLabel = self.resultTextView
        }
    }
    
    private func applyAnimations() {
        trigoModeButton.frame.origin.y -= scaled(100)
        scientificModeButton.frame.origin.y -= scaled(100)
        UIView.animate(withDuration: 0.5) {
            self.trigoModeButton.frame.origin.y += scaled(100)
            self.scientificModeButton.frame.origin.y += scaled(100)
        }
    }

}

// MARK: SKeyboardViewDelegate Conformance
extension MainViewController: SKeyboardViewDelegate {
    
    var textViewForInput: SInputTextView? {
        return inputTextView
    }
    
    var bottomInset: CGFloat {
        return view.safeAreaInsets.bottom
    }
}
