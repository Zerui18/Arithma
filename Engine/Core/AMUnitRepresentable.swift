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
    
    func convertToBase(value: HPAComplex) -> HPAComplex
    
    func convertFromBase(value: HPAComplex) -> HPAComplex
    
}
