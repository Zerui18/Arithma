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

extension HPAReal {
    func formatted()-> NSAttributedString {
        let base = description(sf: 10)
        let annotated = NSMutableAttributedString(string: description(sf: 10), attributes: [.font: resultFont, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)])
        if let symbolIndex = base.index(of: "e") {
            // eleviate exponent
            let expStart = base.index(after: symbolIndex)
            annotated.addAttributes([.font: smallerResultFont, .baselineOffset: 31.0], range: NSRange(location: expStart.encodedOffset, length: base.count-expStart.encodedOffset))
        }
        return annotated
    }
}


extension HPAComplex {
    
    mutating func formatted()-> NSMutableAttributedString {
        let annotated = NSMutableAttributedString()
        if !re.isZero || im.isZero {
            // only append real component if it's not 0 || i=0
            annotated.append(re.formatted())
            if !im.isZero && im.sign() == .plus {
                // only append + connector if both real and imaginary not 0, i > 0
                annotated.append(NSAttributedString(string: "+", attributes: [.font: resultFont, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), .baselineOffset: 0.0]))
            }
        }
        if !im.isZero {
            // only append imaginary component is it's not 0
            annotated.append(im.formatted())
            annotated.append(NSAttributedString(string: "i", attributes: [.font: resultFont, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), .baselineOffset: 0.0]))
        }
        return annotated
    }
    
}

