//
//  CoffeeViewController.swift
//  SiriShortcuts
//
//  Created by Daniel Klein on 22.08.18.
//  Copyright © 2018 Daniel Klein. All rights reserved.
//

import UIKit
import CoreSpotlight
import CoreServices
import IntentsUI

class CoffeeViewController: UIViewController, INUIAddVoiceShortcutButtonDelegate, INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {
    var coffee: Coffee!
    
    @IBOutlet weak var coffeeDescriptionLabel: UILabel!
    
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return true
        }
        set {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = coffee.description
        self.coffeeDescriptionLabel.text = coffee.detailedDescription
        
        // Add to Siri button
        let shortcutButton = INUIAddVoiceShortcutButton(style: .whiteOutline)
        shortcutButton.shortcut = INShortcut(intent: ShortcutsManager.createOrderCoffeeIntent(withCoffee: coffee))
        shortcutButton.delegate = self
        self.view.addSubview(shortcutButton)
        shortcutButton.translatesAutoresizingMaskIntoConstraints = false
        shortcutButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        shortcutButton.topAnchor.constraint(equalToSystemSpacingBelow: self.coffeeDescriptionLabel.bottomAnchor, multiplier: 4).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Donate shortcut
        let activity = NSUserActivity(activityType: "Show Coffee")
        let showString = NSString.deferredLocalizedIntentsString(with: "Show") as String
        activity.title = showString + " " + coffee.description
        activity.userInfo?["coffee"] = coffee?.rawValue
        activity.isEligibleForPrediction = true
        activity.suggestedInvocationPhrase = showString + " " + coffee.description
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier("Show Coffee")
        self.userActivity = activity
    }
    
    @IBAction func orderCoffeeButtonTouched(_ sender: Any) {
        print("Ordering!")
        
        // Performing virtual order here...
        
        // Donate order
        let orderIntent = ShortcutsManager.createOrderCoffeeIntent(withCoffee: coffee)
        let orderInteraction = INInteraction(intent: orderIntent, response: nil)
        let identifier = NSString.deferredLocalizedIntentsString(with: "Order Coffee") as String
        orderInteraction.identifier = identifier
        orderInteraction.donate()

        // Show alert
        let alert = UIAlertController(title: "Coffee Ordered", message: "Your coffee has been ordered. It is ready in 10 minutes.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK:- INUIAddVoiceShortcutButtonDelegate
    
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }

    // MARK:- INUIAddVoiceShortcutViewControllerDelegate
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    // MARK:- INUIEditVoiceShortcutViewControllerDelegate

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
