//
//  AMKeyDescription.swift
//  ArithmaKeyboard
//
//  Created by Chen Zerui on 10/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

/// Struct describing the appearance of a key.
public struct AMKeyDescription {
    
    /// The symbol to be displayed on the key.
    let symbol: String
    /// The style of the key.
    let style: KeyStyle
    
    enum KeyStyle {
        case number, constant, `operator`, function, delete, solve
        
        var highlightedTextColor: UIColor {
            switch self {
            case .number, .constant:
                return #colorLiteral(red: 0.1315293405, green: 0.6848516753, blue: 0.9381706001, alpha: 1)
            case .operator:
                return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            case .function:
                return #colorLiteral(red: 0.4478083688, green: 0.2266379278, blue: 1, alpha: 1)
            case .delete:
                return #colorLiteral(red: 0.7335025381, green: 0, blue: 0.2971241429, alpha: 1)
            case .solve:
                return .white
            }
        }
        
        var highlightedCircleColor: UIColor {
            switch self {
            case .number, .constant:
                return #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            case .operator:
                return #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
            case .function:
                return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            case .delete:
                return #colorLiteral(red: 1, green: 0.6178299837, blue: 0.734453436, alpha: 1)
            case .solve:
                return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
        }
        
    }
    
}
