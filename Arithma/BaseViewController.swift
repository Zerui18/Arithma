//
//  BaseViewController.swift
//  SigMa.th
//
//  Created by Chen Zerui on 29/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import HPAKit
import Settings

class BaseViewController: UIViewController {
    
    // MARK: Singleton
    static let shared = BaseViewController()
    
    // MARK: Private Properties
    private let trigoModeButton = ToggleButton(colors: (#colorLiteral(red: 0.7163728282, green: 0.9372549057, blue: 0.8692806858, alpha: 1), #colorLiteral(red: 0.4371609821, green: 0.5123683887, blue: 0.9686274529, alpha: 1)), labels: ("D", "R"), propertyPath: \AMSettings.isDegreeMode)
    private let scientificModeButton = ToggleButton(colors: (#colorLiteral(red: 0.5568627715, green: 0.4501634074, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)), labels: ("S", "N"), propertyPath: \AMSettings.isScientificMode)
    private let messageLabel = UILabel(frame: .zero)
    private lazy var hideTimer = Debouncer(.seconds(2), queue: .main) {
        UIView.animate(withDuration: 0.2) {
            self.messageLabel.alpha = 0
        }
    }
    
    private let containerScrollView = UIScrollView(frame: .zero)
    private let viewControllers = [PolynomialViewController.shared, CalculatorViewController()]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContainer()
        setupChildren()
        setupOverlayes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyAnimations()
    }
    
    func displayMessage(_ text: String) {
        messageLabel.animateText(to: text)
        hideTimer.call()
    }
    
    // MARK: Private Setups
    
    private func setupContainer() {
        containerScrollView.backgroundColor = nil
        containerScrollView.frame = view.bounds
        containerScrollView.isPagingEnabled = true
        containerScrollView.bounces = false
        containerScrollView.delegate = self
        containerScrollView.showsHorizontalScrollIndicator = false
        containerScrollView.showsVerticalScrollIndicator = false
        containerScrollView.contentSize = CGSize(width: 2*containerScrollView.bounds.width, height: containerScrollView.bounds.height)
        containerScrollView.contentOffset = CGPoint(x: containerScrollView.bounds.width, y: 0)
        view.addSubview(containerScrollView)
    }
    
    private func setupChildren() {
        viewControllers.forEach(self.addChild)
        containerScrollView.addSubview(viewControllers[0].view)
        viewControllers[1].view.frame.origin = containerScrollView.contentOffset
        containerScrollView.addSubview(viewControllers[1].view)
    }
    
    private func setupOverlayes() {
        // Toggle Buttons
        scientificModeButton.translatesAutoresizingMaskIntoConstraints = false
        trigoModeButton.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: scaled(15))
        messageLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        messageLabel.text = "Hello"
        messageLabel.alpha = 0
        
        // Toggle Buttons
        let buttonDim = scaled(36)
        view.addSubview(scientificModeButton)
        scientificModeButton.topAnchor
            .constraint(equalTo: view.topAnchor, constant: scaled(20)).isActive = true
        scientificModeButton.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: scaled(20)).isActive = true
        scientificModeButton.widthAnchor
            .constraint(equalToConstant: buttonDim).isActive = true
        scientificModeButton.heightAnchor
            .constraint(equalToConstant: buttonDim).isActive = true
        
        view.addSubview(trigoModeButton)
        trigoModeButton.topAnchor
            .constraint(equalTo: scientificModeButton.topAnchor).isActive = true
        trigoModeButton.trailingAnchor
            .constraint(equalTo: view.trailingAnchor, constant: scaled(-20)).isActive = true
        trigoModeButton.widthAnchor
            .constraint(equalToConstant: buttonDim).isActive = true
        trigoModeButton.heightAnchor
            .constraint(equalToConstant: buttonDim).isActive = true
        
        view.addSubview(messageLabel)
        messageLabel.topAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: scaled(10)).isActive = true
        messageLabel.centerXAnchor
            .constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    private func applyAnimations() {
        // slide down animation on both toggle buttons
        let offset = scaled(100)
        trigoModeButton.frame.origin.y -= offset
        scientificModeButton.frame.origin.y -= offset
        UIView.animate(withDuration: 0.5) {
            self.trigoModeButton.frame.origin.y += offset
            self.scientificModeButton.frame.origin.y += offset
        }
    }

}

extension BaseViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        if offset == 0 {
            // in polynomials page
            viewControllers[0].becomeFirstResponder()
        }
        else {
            // in calculator page
            viewControllers[1].becomeFirstResponder()
        }
    }
    
}
