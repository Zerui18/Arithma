//
//  HPAReal+Extension.swift
//  HPAKit
//
//  Created by Chen Zerui on 26/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation
import HPA

fileprivate let radianX: HPAReal = xPi / 180
fileprivate let degreeX: HPAReal = 180 / xPi

extension HPAReal {
    
    public var toComplex: HPAComplex {
        return HPAComplex(re: self, im: .zero)
    }
    
    public var toDouble: Double {
        return xtodbl(self)
    }
    
    public var toRadian: HPAReal {
        return self * radianX
    }
    
    public var toDegree: HPAReal {
        return self * degreeX
    }
    
}
