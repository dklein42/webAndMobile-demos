//
//  AppDelegate.swift
//  Handoff
//
//  Created by Daniel Klein on 30.01.19.
//  Copyright © 2019 House of Bytes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}

    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        print("Will continue with type: \(userActivityType)")
        
        switch userActivityType {
        case HelloHandoffViewController.helloHandoffActivityType:
            return true
        case EditorViewController.editUserActivityType:
            return true
        case NSUserActivityTypeBrowsingWeb:
            return true
        default:
            return false
        }
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        print("Updating user activity...")
        userActivity.addUserInfoEntries(from: ["Version" : "1.0"])
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let navigationController = self.window?.rootViewController as! UINavigationController
        navigationController.popToRootViewController(animated: true)

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

        if userActivity.activityType == HelloHandoffViewController.helloHandoffActivityType {
            let helloVC = mainStoryboard.instantiateViewController(withIdentifier: "HelloHandoffViewController")
            restorationHandler([helloVC])
            navigationController.pushViewController(helloVC, animated: true)
            return true
        }
        else if userActivity.activityType == EditorViewController.editUserActivityType {
            let editVC = mainStoryboard.instantiateViewController(withIdentifier: "EditorViewController")
            restorationHandler([editVC])
            navigationController.pushViewController(editVC, animated: true)
            return true
        }
        else if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                print("Opening URL: \(url)")
                // Open content...
            }
        }
        
        return false
    }

    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        print("Continuing user activity failed!")
        
        let nsError = error as NSError

        if nsError.code == NSUserCancelledError {
            print("User cancelled!")
        }
        
    }
}

