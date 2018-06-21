//
//  Token+Highlight.swift
//  NumiBackend
//
//  Created by Chen Zerui on 30/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

extension AMLexer.Token {
    
    var syntaxColor: UIColor {
        switch self {
        case .function:
            return #colorLiteral(red: 0.4478083688, green: 0.2266379278, blue: 1, alpha: 1)
        case .`operator`:
            return .white
        case .parensClose, .parensOpen:
            return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        case .value, .imaginaryUnit:
            return #colorLiteral(red: 0.2392156863, green: 0.6745098039, blue: 0.968627451, alpha: 1)
        case .unit:
            return #colorLiteral(red: 0.1829208135, green: 0.5398121641, blue: 0.831140706, alpha: 1)
        case .identifier:
            return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        }
    }
    
}
