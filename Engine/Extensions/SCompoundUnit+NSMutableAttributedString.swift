//
//  SCompoundUnit+NSMutableAttributedString.swift
//  NumCodeBackend
//
//  Created by Chen Zerui on 3/4/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

extension SCompoundUnit {
    public func addUnitDescription(to attrStr: NSMutableAttributedString) {
        for (unit, power) in baseUnitToPower {
            attrStr.append(NSAttributedString(string: unit.description, attributes: [.font: resultFont, .baselineOffset: 0, .foregroundColor: #colorLiteral(red: 0.1829208135, green: 0.5398121641, blue: 0.831140706, alpha: 1)]))
            attrStr.append(NSAttributedString(string: String(power), attributes: [.font: smallerResultFont, .baselineOffset: scaled(30), .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)]))
        }
    }
}

let resultFont = UIFont(name: "CourierNewPSMT", size: scaled(60))!
let smallerResultFont = UIFont(name: "CourierNewPSMT", size: scaled(45))!
