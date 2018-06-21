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
    
    override func draw(_ rect: CGRect) {
        // draw horitzontal line of 1pt thickness, vertically centered with 20pt side margin
        let path = UIBezierPath(rect:
            CGRect(x: scaled(20), y: rect.height/2 - 0.5, width: rect.width - scaled(40), height: 1)
        )
        #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).setFill()
        path.fill()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = nil
        contentView.backgroundColor = nil
        
        label.textColor = .white
        label.font = labelFont
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .black
        
        contentView.addSubview(label)
        label.widthAnchor.constraint(equalToConstant: scaled(80)).isActive = true
        label.heightAnchor.constraint(equalToConstant: scaled(60)).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate let labelFont = UIFont(name: "CourierNewPSMT", size: scaled(30))!
