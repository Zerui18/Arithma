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
    public func formatted(sf: Int32 = 7, customFontSize: CGFloat? = nil)-> NSAttributedString {
        let normalFont: UIFont
        
        if let size = customFontSize {
            normalFont = resultFont.withSize(size)
        }
        else {
            normalFont = resultFont
        }
        
        let base = description(sf: sf)
        let annotated = NSMutableAttributedString(string: base, attributes: [.font: normalFont, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)])
        if let symbolIndex = base.firstIndex(of: "e") {
            // eleviate exponent
            annotated.addAttributes([.foregroundColor: UIColor.white], range: NSRange(location: symbolIndex.utf16Offset(in: base), length: 1))
        }
        return annotated
    }
}


extension HPAComplex {
    
    public mutating func formatted(sf: Int32 = 7, customFontSize: CGFloat? = nil)-> NSMutableAttributedString {
        let normalFont: UIFont
        
        if let size = customFontSize {
            normalFont = resultFont.withSize(size)
        }
        else {
            normalFont = resultFont
        }
        
        let annotated = NSMutableAttributedString()
        if !re.isZero || im.isZero {
            // only append real component if it's not 0 || i=0
            annotated.append(re.formatted(sf: sf, customFontSize: customFontSize))
            if !im.isZero && im.sign() == .plus {
                // only append + connector if both real and imaginary not 0, i > 0
                annotated.append(NSAttributedString(string: "+", attributes: [.font: normalFont, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), .baselineOffset: 0.0]))
            }
        }
        if !im.isZero {
            // only append imaginary component is it's not 0
            annotated.append(im.formatted(sf: sf, customFontSize: customFontSize))
            annotated.append(NSAttributedString(string: "i", attributes: [.font: normalFont, .foregroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), .baselineOffset: 0.0]))
        }
        return annotated
    }
    
}

extension HPAPolynomial {
    
    public func formatted(fontSize: CGFloat)-> NSMutableAttributedString {
        let str = NSMutableAttributedString()
        
        // cached properties
        let baseFont = resultFont.withSize(fontSize)
        let expoFont = resultFont.withSize(fontSize * 0.75)
        let baseline = fontSize * 0.5
        let baseAttrs = [NSAttributedString.Key.font: baseFont, .foregroundColor: UIColor.white, .baselineOffset: 0.0] as [NSAttributedString.Key : Any]
        
        for (degree, coefficient) in coefficients.enumerated().reversed() {
            // add plus sign if necessary
            if degree < coefficients.count-1 && coefficient.sign() == .plus {
                str.append(NSAttributedString(string: "+", attributes: baseAttrs))
            }
            // add coefficient
            str.append(coefficient.formatted(sf: 4, customFontSize: fontSize))
            
            if degree > 0 {
                // add degree (x^n)
                let substr = NSMutableAttributedString(string: "x\(degree)", attributes: baseAttrs)
                substr.addAttributes([.font: expoFont, .baselineOffset: baseline, .foregroundColor: #colorLiteral(red: 0.2392156863, green: 0.6745098039, blue: 0.968627451, alpha: 1)], range: NSRange(location: 1, length: 1))
                str.append(substr)
            }
        }
        
        str.append(NSAttributedString(string: "=0", attributes: baseAttrs))
        str.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.2392156863, green: 0.6745098039, blue: 0.968627451, alpha: 1), range: NSRange(location: str.length-1, length: 1))
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        str.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: str.length))
        return str
    }
    
}
