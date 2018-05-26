//
//  SUnitRepresentable.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import ExtMathLib
import CComplex

public protocol SUnitRepresentable: Equatable, CustomStringConvertible {
    
    func canConvert(to unit: Self) -> Bool
    
    func convertToBase(value: CComplex) -> CComplex
    
    func convertFromBase(value: CComplex) -> CComplex
    
}
