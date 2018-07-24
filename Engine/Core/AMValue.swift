//
//  AMValue.swift
//  NumiBackend
//
//  Created by Chen Zerui on 31/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import HPAKit
import Settings
import MobileCoreServices

public class AMValue: Equatable, CustomStringConvertible {
    
    public var value: HPAComplex
    public var unit: AMCompoundUnit
    public weak var boundLabel: UIView? {
        didSet {
            boundLabel?.setValue(attributedDescription, forKey: "attributedText")
        }
    }
    public var fontSize: CGFloat?
    
    /**
     Initializes a AMValue instance with a scalar value and a unit
     */
    public init(value: HPAComplex, unit: AMCompoundUnit = .init()) {
        self.value = value
        self.unit = unit
        
        NotificationCenter.default.addObserver(forName: .displayModeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.boundLabel?.setValue(self?.attributedDescription, forKey: "attributedText")
        }
    }
    
    var hasUnit: Bool {
        return !unit.unitToPower.isEmpty
    }
    
    func valueInBaseUnit() -> HPAComplex {
        return unit.convertToBase(value: value)
    }
    
    /**
     Create a new AMValue representing the receiver's value in the given unit. The target unit must share/be the baseUnit of the receiver.
     - parameters:
        - unit: the desired unit
     - throws: an error if unit cast is not possible
     - returns: the newly constructed NumiUnit instance
     */
    public func convertedTo(unit: AMCompoundUnit) throws -> AMValue {
        
        guard self.unit.canConvert(to: unit) else {
            throw OperationError.unitConversionFailed(self.unit, unit)
        }
        let baseUnitValue = valueInBaseUnit()
        let convertedValue = unit.convertFromBase(value: baseUnitValue)

        return AMValue(value: convertedValue, unit: unit)
    }
    
    public static func ==(_ lhs: AMValue, _ rhs: AMValue)-> Bool {
        return lhs.value == rhs.value && lhs.unit == rhs.unit
    }
    
    
    /**
     Debug description of the receiver's value in base units.
     */
    public var description: String {
        return valueInBaseUnit().description(sf: 10) + unit.description
    }
    
    /**
     Create a NSMutableAttributedString for UI display of the receiver's value.
     */
    public var attributedDescription: NSMutableAttributedString {
        var value = valueInBaseUnit()
        let str = value.formatted(customFontSize: fontSize)
        unit.addUnitDescription(to: str)
        return str
    }
    
    /**
     Copies the attributed description (not the same as the property with the same name) into the app's clipboard. The font size is adjusted to match that of the AMInputTextView.
     */
    public func copyAttributedDescription() {
        var value = valueInBaseUnit()
        let str = value.formatted(customFontSize: scaled(40))
        unit.addUnitDescription(to: str, customFontSize: scaled(40))
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        str.addAttributes([.paragraphStyle: style], range: NSRange(location: 0, length: str.length))
        
        let rtfData = try! str.data(from: NSRange(location: 0, length: str.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        let item = [kUTTypeRTF as String: rtfData, kUTTypeUTF8PlainText as String: str.string] as [String: Any]
        UIPasteboard.general.setItems([item])
    }

}
