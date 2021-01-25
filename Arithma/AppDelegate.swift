//
//  AppDelegate.swift
//  Arithma
//
//  Created by Chen Zerui on 4/2/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine
import HPAKit
import Touch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
//                                                          morphEnabled: false,
//                                                          touchVisibility: .remoteAndLocal,
//                                                          contactConfig: nil,
//                                                          rippleConfig: nil)
    private var hasSetupUnits = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UITextView.patch()
        AMInterpreter.setup()
        UITextView.appearance().tintColor = .white
        setupWindow()
        addUnits()
        return true
    }
    
    private func setupWindow() {
        window!.rootViewController = BaseViewController.shared
        window!.makeKeyAndVisible()
        window!.backgroundColor = .white
    }
    
    private func addUnits() {
        guard !hasSetupUnits else {
            return
        }
        
        hasSetupUnits = true
        _ = +>"m" ~~ ("mm", 1e-3) ~~ ("cm", 1e-2) ~~ ("km", 1e3)
        _ = +>"s" ~~ ("min", 60) ~~ ("hr", 3600) ~~ ("day", 3600*24)
        _ = +>"kg" ~~ ("mg", 1e-6) ~~ ("g", 1e-3) ~~ ("ton", 1e3)
        _ = +>"A" ~~ ("µA", 1e-6) ~~ ("mA", 1e-3) ~~ ("kA", 1e3)
        _ = +>"K" ~~ ("µK", 1e-6) ~~ ("mK", 1e-3) ~~ ("kK", 1e3)
        _ = +>"mol" ~~ ("mmol", 1e-3) ~~ ("kmol", 1e3)
    }

}

