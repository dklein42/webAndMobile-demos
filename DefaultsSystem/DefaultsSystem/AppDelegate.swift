//
//  AppDelegate.swift
//  DefaultsSystem
//
//  Created by Daniel Klein on 07.05.19.
//  Copyright © 2019 Daniel Klein. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let testKey = "Some Test Key"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let defaults = UserDefaults.standard
        
        let didAgreeKey = "Did Agree"
        defaults.set(true, forKey: didAgreeKey)
        let didAgree = defaults.bool(forKey: didAgreeKey)
        print("The value is: \(didAgree)")
        
        // Numbers
        let theAnswerKey = "The Answer"
        defaults.set(42, forKey: theAnswerKey)
        let theAnswer = defaults.integer(forKey: theAnswerKey)
        print("The answer is: \(theAnswer)")
        
        let piKey = "Pi"
        defaults.set(Double.pi, forKey: piKey)
        let readPi = defaults.double(forKey: piKey)
        print("Pi is: \(readPi)")
        
        // Strings
        let forenameKey = "Forename"
        defaults.set("Daniel", forKey: forenameKey)
        let maybeForename = defaults.string(forKey: forenameKey)
        
        if let forename = maybeForename {
            print("Forename is: \(forename)")
        }
        
        // Date
        let dateKey = "Date"
        defaults.set(Date(), forKey: dateKey)
        let readDateKey = defaults.object(forKey: dateKey)!
        print("Date is: \(String(describing: readDateKey))")
        
        
        // URL
        let urlKey = "URL"
        defaults.set(URL(string: "https://www.webundmobile.de"), forKey: urlKey)
        let readURL = defaults.url(forKey: urlKey)!
        print("URL is: \(String(describing: readURL))")
        
        // Data
        let dataKey = "Data"
        let data = Data("ABCDEFG".utf8)
        defaults.set(data, forKey: dataKey)
        let readData = defaults.data(forKey: dataKey)
        let readString = String(data: readData!, encoding: String.Encoding.utf8)!
        print("The data is: \((readData! as NSData).description)")
        print("Read string is: \(readString)")
        
        // collections
        let ar1 = [1, 2, 3]
        let ar1Key = "AR1"
        defaults.set(ar1, forKey: ar1Key)
        let readAr1 = defaults.array(forKey: ar1Key)! as! [Int]
        print("Elements are: \(String(describing: readAr1))")
        
        // String special variant
        let strings = ["A", "B", "C"]
        let stringsKey = "Strings"
        defaults.set(strings, forKey: stringsKey)
        let readStrings = defaults.stringArray(forKey: stringsKey)! // Optional!
        print("Read strings are: \(String(describing: readStrings))")
        
        // Dictionaries
        let dict1 = ["a" : 1, "b" : 2, "c" : 3]
        let dict1Key = "Dict1"
        defaults.set(dict1, forKey: dict1Key)
        let readDict1 = defaults.dictionary(forKey: dict1Key)! as! [String:Int]
        print("The dict is: \(String(describing: readDict1))")
        
        // Register
        //let testKey = "Test"
        let testBefore = defaults.integer(forKey: testKey)
        print("testBefore is: \(testBefore)")
        
        let defaultValues: [String : Any] = [
            didAgreeKey : true,
            piKey : Double.pi,
            "Some Values" : [1.0, 1.1, 1.2],
            "Some Data" : Data("abc".utf8),
            testKey : 1
        ]
        defaults.register(defaults: defaultValues)
        
        let testAfter = defaults.integer(forKey: testKey)
        print("testAfter is: \(testAfter)")

        defaults.set(42, forKey: testKey)
        
        let testLast = defaults.integer(forKey: testKey)
        print("testLast is: \(testLast)")
        
        // Remove
        defaults.removeObject(forKey: testKey)
        
        // Monitor all changes
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: UserDefaults.standard, queue: OperationQueue.main) { (notification) in
            // notification doesn't contain anything usefull in that case
            print("Some User Defaults have been changed!")
        }

        // KVO: Monitor specific keys
        defaults.addObserver(self, forKeyPath: testKey, options: [.new, .old, .initial], context: nil)
        

        defaults.set(43, forKey: testKey)
        defaults.set(44, forKey: testKey)
        defaults.set(45, forKey: testKey)
        
        // Command line arguments
        // Set in "Arguments" tab in Scheme settings
        let doSomethingKey = "DO_SOMETHING"
        
        defaults.set(false, forKey: doSomethingKey)
        
        let readDoSomething = defaults.bool(forKey: doSomethingKey)
        print("DO_SOMETHING is: \(readDoSomething)")
        
        // iCloud Key/Value Store
        // Setup in Capabilities, com.apple.developer.ubiquity-kvstore-identifier entitlement
        
        let store = NSUbiquitousKeyValueStore.default
        
        let iCloudTestKey = "iCloud Test"
        store.set(Double.random(in: 0...99), forKey: iCloudTestKey)
        let readFromiCloud = store.double(forKey: iCloudTestKey)
        print("Value from iCloud is: \(readFromiCloud)")
        store.synchronize()
        
        // No Int, just Int64!
        let intTest = "Int Test"
        store.set(42, forKey: intTest)
        let readIntTest = store.longLong(forKey: intTest)
        print("Long long is: \(readIntTest)")
        
        // Get change notifications
        NotificationCenter.default.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default, queue: OperationQueue.main) { (notification) in
            print("iCloud Key/Value store changed from the outside! Notification: \(notification)")
            
            guard let userInfo = notification.userInfo else { return }
            
            let changeReason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey]!
            print("Change reason is: \(changeReason)")
            
            let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey]! as! [String]
            print("These keys have changed: \(changedKeys)")
            
            if changedKeys.contains(iCloudTestKey) {
                print("iCloudTestKey did change!")
                let newValue = NSUbiquitousKeyValueStore.default.double(forKey: iCloudTestKey)
                print("New value is: \(newValue)")
            }
        }

        // Shared Defaults
        let sharedDefaults = UserDefaults(suiteName: "group.test.hobsoft")!
        
        sharedDefaults.set(true, forKey: testKey)
        let readSharedTest = sharedDefaults.bool(forKey: testKey)
        print("Shared value is: \(readSharedTest)")

        return true
    }

    func dealloc() {
        UserDefaults.standard.removeObserver(self, forKeyPath: testKey)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == testKey, let change = change {
            let old = change[.oldKey] ?? "n/a"
            let new = change[.newKey]!
            print("Observing key: \(keyPath!), old: \(old) new: \(new)")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

