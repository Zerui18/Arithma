//
//  UIView+Constraints.swift
//  SigMa.th
//
//  Created by Chen Zerui on 28/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

fileprivate var key = 0

public enum AnchorType: String {
    case leading, trailing, top, bottom, centerX, centerY
    
    fileprivate var associatedView: UIView? {
        get {
            return objc_getAssociatedObject(self, &key) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var isYAxis: Bool {
        switch self {
        case .top, .bottom, .centerY:
            return true
        default:
            return false
        }
    }
    
    public var name: String {
        return "\(self)Anchor"
    }
}

fileprivate var currentView: UIView?
fileprivate var useSafeArea = true

extension UIView {
    
    public subscript(anchor: AnchorType)-> AnchorType {
        var anchor = anchor
        anchor.associatedView = self
        return anchor
    }
    
}

@inline(__always)
fileprivate func getXAnchor(_ type: AnchorType)-> NSLayoutXAxisAnchor {
    let view = type.associatedView ?? currentView!
    let target: NSObject = useSafeArea ? view.safeAreaLayoutGuide:view
    return target.value(forKey: type.name) as! NSLayoutXAxisAnchor
}

@inline(__always)
fileprivate func getYAnchor(_ type: AnchorType)-> NSLayoutYAxisAnchor {
    let view = type.associatedView ?? currentView!
    let target: NSObject = useSafeArea ? view.safeAreaLayoutGuide:view
    return target.value(forKey: type.name) as! NSLayoutYAxisAnchor
}

infix operator ||>: MultiplicationPrecedence
infix operator ||<: MultiplicationPrecedence
infix operator ||=: MultiplicationPrecedence

infix operator ~~: AdditionPrecedence

@discardableResult
public func ||>(anchor1: AnchorType, anchor2: AnchorType)-> NSLayoutConstraint {
    guard anchor1.isYAxis == anchor2.isYAxis else {
        fatalError("Anchors of different axis.")
    }
    
    let constraint: NSLayoutConstraint
    
    if anchor1.isYAxis {
        constraint = getYAnchor(anchor1).constraint(greaterThanOrEqualTo: getYAnchor(anchor2))
    }
    else {
        constraint = getXAnchor(anchor1).constraint(greaterThanOrEqualTo: getXAnchor(anchor2))
    }
    
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ||<(anchor1: AnchorType, anchor2: AnchorType)-> NSLayoutConstraint {
    guard anchor1.isYAxis == anchor2.isYAxis else {
        fatalError("Anchors of different axis.")
    }
    
    let constraint: NSLayoutConstraint
    
    if anchor1.isYAxis {
        constraint = getYAnchor(anchor1).constraint(lessThanOrEqualTo: getYAnchor(anchor2))
    }
    else {
        constraint = getXAnchor(anchor1).constraint(lessThanOrEqualTo: getXAnchor(anchor2))
    }
    
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ||=(anchor1: AnchorType, anchor2: AnchorType)-> NSLayoutConstraint {
    guard anchor1.isYAxis == anchor2.isYAxis else {
        fatalError("Anchors of different axis.")
    }
    
    let constraint: NSLayoutConstraint
    
    if anchor1.isYAxis {
        constraint = getYAnchor(anchor1).constraint(equalTo: getYAnchor(anchor2))
    }
    else {
        constraint = getXAnchor(anchor1).constraint(equalTo: getXAnchor(anchor2))
    }
    
    constraint.isActive = true
    return constraint
}

@inline(__always)
public func ~~(constraint: NSLayoutConstraint, constant: CGFloat) {
    constraint.constant = constant
}
