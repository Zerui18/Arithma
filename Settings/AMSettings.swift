//
//  AMSettings.swift
//  Arithma
//
//  Created by Chen Zerui on 30/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation

public final class AMSettings {
    
    public static let shared = AMSettings()
    
    private init() {}
    
    public var isDegreeMode: Bool {
        get {
            return trigoModeRaw == 0
        }
        set {
            trigoModeRaw = newValue ? 0:1
        }
    }
    
    public var trigoModeRaw: Int {
        get {
            return UserDefaults.standard.integer(forKey: "trigoMode")
        }
        set {
            if trigoModeRaw != newValue {
                UserDefaults.standard.set(newValue, forKey: "trigoMode")
                NotificationCenter.default.post(name: .calcModeChanged, object: nil)
            }
        }
    }
    
    public var isScientificMode: Bool {
        get {
            // 0 is default (non scientific)
            return scientificModeRaw != 0
        }
        set {
            scientificModeRaw = newValue ? 1:0
        }
    }
    
    private var scientificModeRaw: Int {
        get {
            return UserDefaults.standard.integer(forKey: "scMode")
        }
        set {
            if scientificModeRaw != newValue {
                UserDefaults.standard.set(newValue, forKey: "scMode")
                NotificationCenter.default.post(name: .displayModeChanged, object: nil)
            }
        }
    }
    
}
