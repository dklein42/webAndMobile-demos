//
//  AppDelegate.swift
//  SiriShortcuts
//
//  Created by Daniel Klein on 18.08.18.
//  Copyright © 2018 Daniel Klein. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Init ShortcutsManager and register suggestions
        _ = ShortcutsManager.shared

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let rawCoffee = userActivity.userInfo?["coffee"] as? String else {
            return false
        }
        
        let coffeeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Coffee View Controller") as! CoffeeViewController
        coffeeVC.coffee = Coffee(rawValue: rawCoffee)

        let navigationVC = self.window?.rootViewController as! UINavigationController
        navigationVC.popToRootViewController(animated: true)
        navigationVC.pushViewController(coffeeVC, animated: true)
        
        return true
    }    
}

