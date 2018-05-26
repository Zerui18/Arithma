//
//  ViewController.swift
//  Numi
//
//  Created by Chen Zerui on 27/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import NumCodeBackend
import NumCodeKeyboard
import NumCodeSettings

// TODO: Auto-scaling of UI components & fonts

//Private Input-components
fileprivate let keyboard = NCKeyboardView(size: CGSize(width: UIScreen.main.bounds.width,
                                                       height: UIScreen.main.bounds.height*0.6))
fileprivate let unitSelector = NCUnitSelectorView(keyboard: keyboard)

// MARK: MainViewController class
class MainViewController: UIViewController {
    
    
    static let shared = MainViewController()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Private Properties
    private let trigoModeButton = ToggleButton(colors: (#colorLiteral(red: 0.7163728282, green: 0.9372549057, blue: 0.8692806858, alpha: 1), #colorLiteral(red: 0.4371609821, green: 0.5123683887, blue: 0.9686274529, alpha: 1)), labels: ("D", "R"), propertyPath: \NCSettings.isDegreeMode)
    private let scientificModeButton = ToggleButton(colors: (#colorLiteral(red: 0.5568627715, green: 0.4501634074, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)), labels: ("S", "N"), propertyPath: \NCSettings.isScientificMode)
    
    private let resultLabel = UITextView(frame: .zero)
    private lazy var resultScrollView = ContainerScrollView(wrapping: resultLabel)
    
    private let inputTextView = NCInputTextView(frame: .zero, keyboard: keyboard)
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
        scientificModeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat(16).scaled).isActive = true
        scientificModeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(16).scaled).isActive = true
        scientificModeButton.widthAnchor.constraint(equalToConstant: CGFloat(36).scaled).isActive = true
        scientificModeButton.heightAnchor.constraint(equalToConstant: CGFloat(36).scaled).isActive = true
        
        
        trigoModeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(trigoModeButton)
        trigoModeButton.topAnchor.constraint(equalTo: scientificModeButton.topAnchor).isActive = true
        trigoModeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-16).scaled).isActive = true
        trigoModeButton.widthAnchor.constraint(equalToConstant: CGFloat(36).scaled).isActive = true
        trigoModeButton.heightAnchor.constraint(equalToConstant: CGFloat(36).scaled).isActive = true
        
        // Main UI -> Result
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.isOpaque = false
        resultLabel.backgroundColor = nil
        resultLabel.isScrollEnabled = false
        
        resultLabel.leadingAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.leadingAnchor, constant: 16).isActive = true
        resultLabel.trailingAnchor.constraint(lessThanOrEqualTo: resultScrollView.trailingAnchor, constant: -16).isActive = true
        
        resultScrollView.translatesAutoresizingMaskIntoConstraints = false
        resultScrollView.bounces = false
        resultScrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(resultScrollView)
        resultScrollView.topAnchor.constraint(equalTo: trigoModeButton.bottomAnchor, constant: CGFloat(20).scaled).isActive = true
        resultScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        resultScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        resultScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(74).scaled).isActive = true
        
        
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
        inputScrollView.topAnchor.constraint(equalTo: resultScrollView.bottomAnchor, constant: CGFloat(16).scaled).isActive = true
        inputScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        inputScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        inputScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(54).scaled).isActive = true
        
        inputTextView.leadingAnchor.constraint(greaterThanOrEqualTo: inputScrollView.leadingAnchor, constant: 16).isActive = true
        inputTextView.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: -16).isActive = true
        inputTextView.trailingAnchor.constraint(equalTo: inputScrollView.trailingAnchor).isActive = true
        // setup scroll as you type
//        inputTextView.onTextChange = {
//            self.inputScrollView.setContentOffset(.zero, animated: false)
//        }
        
        // setup result-update logic
        inputTextView.onResultUpdate = { value, error in
            guard error == nil else {
                
                // blank-out label if it's empty input
                guard !self.inputTextView.text.isEmpty else {
                    self.resultLabel.text = nil
                    return
                }
                
                guard let text = self.resultLabel.attributedText else {
                    return
                }
                
                // else gray-out the displayed result
                let copy = NSMutableAttributedString(attributedString: text)
                copy.addAttribute(.foregroundColor, value: UIColor.darkGray, range: NSRange(location: 0, length: copy.length))
                self.resultLabel.attributedText = copy
                return
            }
            
            // no error
            value!.boundLabel = self.resultLabel
        }
    }
    
    private func applyAnimations() {
        trigoModeButton.frame.origin.y -= CGFloat(100).scaled
        scientificModeButton.frame.origin.y -= CGFloat(100).scaled
        UIView.animate(withDuration: 0.5) {
            self.trigoModeButton.frame.origin.y += CGFloat(100).scaled
            self.scientificModeButton.frame.origin.y += CGFloat(100).scaled
        }
    }

}

// MARK: NCKeyboardViewDelegate Conformance
extension MainViewController: NCKeyboardViewDelegate {
    
    var textViewForInput: NCInputTextView? {
        return inputTextView
    }
    
    var bottomInset: CGFloat {
        return view.safeAreaInsets.bottom
    }
}
