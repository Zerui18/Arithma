//
//  PolynomialResultCell.swift
//  SigMa.th
//
//  Created by Chen Zerui on 17/6/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import HPAKit
import Engine

class PolynomialResultCell: UITableViewCell {
    
    var result: HPAComplex! {
        didSet {
            resultLabel.attributedText = result.formatted(customFontSize: scaled(34))
        }
    }
    let resultLabel = UITextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = nil
        contentView.backgroundColor = nil
        
        resultLabel.backgroundColor = nil
        resultLabel.isScrollEnabled = false
        resultLabel.isUserInteractionEnabled = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(resultLabel)
        resultLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        resultLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor).isActive = true
        resultLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
