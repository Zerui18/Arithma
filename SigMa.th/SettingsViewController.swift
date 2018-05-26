//
//  SettingsViewController.swift
//  NumCode
//
//  Created by Chen Zerui on 30/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import NumCodeBackend
import NumCodeSettings

class SettingsViewController: UIViewController {
    
    let cardBackground = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let trigoModeControl = UISegmentedControl(items: ["Deg", "Rad"])
    let roundModeControl = UISegmentedControl(items: ["Sf", "Dp"])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5956763699)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAnimated)))
        setupLayout()
    }
    
    private func setupLayout() {
        cardBackground.translatesAutoresizingMaskIntoConstraints = false
        cardBackground.clipsToBounds = true
        cardBackground.layer.cornerRadius = 20
        view.addSubview(cardBackground)
        
        cardBackground.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        cardBackground.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        let modeControlLabel = UILabel(frame: .zero)
        modeControlLabel.translatesAutoresizingMaskIntoConstraints = false
        modeControlLabel.text = "Trigo Mode"
        modeControlLabel.font = labelFont
        modeControlLabel.textColor = .white
        
        cardBackground.contentView.addSubview(modeControlLabel)
        modeControlLabel.topAnchor.constraint(equalTo: cardBackground.contentView.topAnchor, constant: 16).isActive = true
        modeControlLabel.centerXAnchor.constraint(equalTo: cardBackground.contentView.centerXAnchor).isActive = true
        modeControlLabel.leadingAnchor.constraint(equalTo: cardBackground.contentView.leadingAnchor, constant: 20).isActive = true
        modeControlLabel.trailingAnchor.constraint(equalTo: cardBackground.contentView.trailingAnchor, constant: -20).isActive = true
        
        
        trigoModeControl.translatesAutoresizingMaskIntoConstraints = false
        trigoModeControl.selectedSegmentIndex = NCSettings.shared.trigoModeRaw
        trigoModeControl.setTitleTextAttributes([NSAttributedStringKey.font: labelFont], for: UIControlState())
        trigoModeControl.tintColor = .white
        
        cardBackground.contentView.addSubview(trigoModeControl)
        trigoModeControl.topAnchor.constraint(equalTo: modeControlLabel.bottomAnchor, constant: 8).isActive = true
        trigoModeControl.centerXAnchor.constraint(equalTo: cardBackground.contentView.centerXAnchor).isActive = true
        trigoModeControl.bottomAnchor.constraint(equalTo: cardBackground.contentView.bottomAnchor, constant: -25).isActive = true
        
        trigoModeControl.addTarget(self, action: #selector(trigoModeChanged), for: .valueChanged)
    }
    
    @objc private func trigoModeChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
        NCSettings.shared.trigoModeRaw = trigoModeControl.selectedSegmentIndex
    }
    
    @objc private func dismissAnimated() {
        self.dismiss(animated: true)
    }
    
}

fileprivate let labelFont = UIFont.systemFont(ofSize: 30)
