//
//  AppDelegate.swift
//  NumCode
//
//  Created by Chen Zerui on 4/2/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine
import HPAKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    private var hasSetupUnits = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SInterpreter.setup()
        UITextView.appearance().tintColor = .white
        setupWindow()
        addUnits()
        return true
    }
    
    private func setupWindow() {
        window!.rootViewController = BaseViewController()
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
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }

}

