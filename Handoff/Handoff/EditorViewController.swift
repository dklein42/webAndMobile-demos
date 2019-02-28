//
//  EditorViewController.swift
//  Handoff
//
//  Created by Daniel Klein on 25.02.19.
//  Copyright © 2019 House of Bytes. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UITextViewDelegate, NSUserActivityDelegate {
    @IBOutlet weak var textView: UITextView!
    
    static let editUserActivityType = "de.hobsoft.demo.Edit"
    let editUserActivityTextKey = "Text"
    
    let editUserActivity = NSUserActivity(activityType: editUserActivityType)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editUserActivity.delegate = self
        editUserActivity.title = "Edit"
        editUserActivity.webpageURL = URL(string: "http://www.example.com/edit")
        self.userActivity = editUserActivity
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("Changed!")
        editUserActivity.needsSave = true
    }
    
    func userActivityWillSave(_ userActivity: NSUserActivity) {
        print("Will save!")
        
        DispatchQueue.main.sync {
            userActivity.addUserInfoEntries(from: [self.editUserActivityTextKey : self.textView.text ?? ""])
        }
    }
    
    func userActivityWasContinued(_ userActivity: NSUserActivity) {
        print("Activity has been continued on another device!")
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        super.restoreUserActivityState(activity)
        print("Restoring state...")
        
        guard let userInfo = activity.userInfo else {
            return
        }
        
        if let text = userInfo[editUserActivityTextKey] as? String {
            textView.text = text
        }
    }
}
