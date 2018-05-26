//
//  HPAComplex+Extension.swift
//  HPAKit
//
//  Created by Chen Zerui on 26/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation


extension HPAComplex {
    
    public var toRadian: HPAComplex {
        return HPAComplex(re: re.toRadian, im: im.toRadian)
    }
    
    public var toDegree: HPAComplex {
        return HPAComplex(re: re.toDegree, im: im.toDegree)
    }
    
}
