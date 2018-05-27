//
//  Double+ScientificNotation.swift
//  NumiConsole
//
//  Created by Chen Zerui on 3/2/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import HPAKit
import Settings

extension Formatter {
    static let scientific: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 4
        formatter.positiveFormat = "0.###E0"
        formatter.exponentSymbol = "e"
        return formatter
    }()
}

extension HPAComplex {
    
    func formatted()-> NSMutableAttributedString {
        return NSMutableAttributedString(string: description(sf: 10), attributes: [.font: resultFont, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), .baselineOffset: 0])
//        Formatter.scientific.maximumSignificantDigits = 4
//
//        if !SSettings.shared.isScientificMode || !isReal {
//            return NSMutableAttributedString(string: description(sf: 5), attributes: [.font: resultFont, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), .baselineOffset: 0])
//        }
//
//        let formatted = Formatter.scientific.string(from: NSNumber(value: re.toDouble))!
//        let components = formatted.components(separatedBy: "e")
//
//        guard components.count > 1 else {
//            return NSMutableAttributedString(string: formatted, attributes: [.font: resultFont, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), .baselineOffset: 0])
//        }
//        let power = Int(components[1])!
//
//        let str = NSMutableAttributedString(string: components[0], attributes: [.font: resultFont, .baselineOffset: 0, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)])
//
//        if power != 0 {
//            str.append(NSAttributedString(string: "×10", attributes: [.font: resultFont, .foregroundColor: #colorLiteral(red: 0.1829208135, green: 0.5398121641, blue: 0.831140706, alpha: 1)]))
//            str.append(NSAttributedString(string: components[1], attributes: [.font: smallerResultFont, .baselineOffset: scaled(), .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)]))
//        }
//
//        return str
    }
    
}
