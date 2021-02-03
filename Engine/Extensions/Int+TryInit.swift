//
//  Int+TryInit.swift
//  Engine
//
//  Created by Zerui Chen on 28/1/21.
//  Copyright © 2021 Chen Zerui. All rights reserved.
//

import Foundation

extension Int {
    
    /**
     Safely initialise an Int with a Double value, throwing a math error if the operation fails.
     */
    init(safelyWith dbl: Double) throws {
        guard abs(dbl) <= Double(Int.max) else {
            throw AMValue.OperationError.mathError
        }
        
        self = Int(dbl)
    }
    
}
