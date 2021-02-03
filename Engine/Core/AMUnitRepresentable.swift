//
//  AMUnitRepresentable.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import HPAKit

public protocol AMUnitRepresentable: Equatable, CustomStringConvertible {
    
    func canConvert(to unit: Self) -> Bool
    
    /**
        Convert a value of this unit to a new value in the base units.
     */
    func convertToBase(value: HPAComplex) -> HPAComplex
    
    /**
        Convert a value in the base units to a value of this unit.
     */
    func convertFromBase(value: HPAComplex) -> HPAComplex
    
}
