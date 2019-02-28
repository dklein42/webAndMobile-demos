//
//  ViewController.swift
//  Handoff
//
//  Created by Daniel Klein on 30.01.19.
//  Copyright © 2019 House of Bytes Software. All rights reserved.
//

import UIKit

class HelloHandoffViewController: UIViewController {
    static let helloHandoffActivityType = "de.hobsoft.demo.HelloHandoff"
    var activity: NSUserActivity!

	override func viewDidLoad() {
		super.viewDidLoad()
		
        activity = NSUserActivity(activityType: HelloHandoffViewController.helloHandoffActivityType)
        activity.title = "Hello Handoff!"
        activity.webpageURL = URL(string: "http://www.example.com/helloHandoff")
        //activity.becomeCurrent()
        self.userActivity = activity
        
        //activity.resignCurrent()
        
        //activity.invalidate()
	}
}

