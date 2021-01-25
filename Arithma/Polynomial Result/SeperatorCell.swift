//
//  SeperatorCell.swift
//  SigMa.th
//
//  Created by Chen Zerui on 20/6/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

class SeperatorCell: UITableViewCell {
    
    var index: Int! {
        didSet {
            label.text = "x\(index+1)"
        }
    }
    
    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = nil
        contentView.backgroundColor = nil
        
        label.textColor = .white
        label.font = labelFont
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .black
        
        contentView.addSubview(label)
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate let labelFont = UIFont(name: "Avenir Next", size: scaled(25))!
