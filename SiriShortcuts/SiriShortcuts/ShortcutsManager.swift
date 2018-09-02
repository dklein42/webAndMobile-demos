//
//  ShortcutsManager.swift
//  My Coffee Shop
//
//  Created by Daniel Klein on 25.08.18.
//  Copyright © 2018 Daniel Klein. All rights reserved.
//

import UIKit
import Intents

class ShortcutsManager: NSObject {
    static let shared = ShortcutsManager()
    
    private override init() {
        super.init()
        registerSuggestions()
        registerRelevantShortcuts()
    }
    
    var suggestions: [INShortcut] {
        let randomCoffee = Coffee.allCases.randomElement()!
        
        let displayString = NSString.deferredLocalizedIntentsString(with: "Coffee of the Day") as String
        let phraseString = NSString.deferredLocalizedIntentsString(with: "Order the coffee of the day") as String
        
        let randomCoffeeIntent = OrderCoffeeIntent()
        randomCoffeeIntent.coffee = INObject(identifier: randomCoffee.rawValue, display: displayString)
        randomCoffeeIntent.suggestedInvocationPhrase = phraseString
        
        let coffeeOfTheDayShortcut = INShortcut(intent: randomCoffeeIntent)!
        return [coffeeOfTheDayShortcut]
    }
    
    var relevantShortcuts: [INRelevantShortcut] {
        let coffeeOfTheDayShortcut = self.suggestions[0]
        let relevantShortcut = INRelevantShortcut(shortcut: coffeeOfTheDayShortcut)
        relevantShortcut.shortcutRole = .action
        relevantShortcut.relevanceProviders = [INDailyRoutineRelevanceProvider(situation: .evening)]
        return [relevantShortcut]
    }

    func registerSuggestions() {
        INVoiceShortcutCenter.shared.setShortcutSuggestions(suggestions)
    }
    
    func registerRelevantShortcuts() {
        INRelevantShortcutStore.default.setRelevantShortcuts(relevantShortcuts, completionHandler: nil)
    }
    
    static func deleteAll() {
        // User Activity
        NSUserActivity.deleteSavedUserActivities(withPersistentIdentifiers: [NSUserActivityPersistentIdentifier("Show Coffee")], completionHandler: {})
        //NSUserActivity.deleteAllSavedUserActivities(completionHandler: {})
        
        // Intents
        INInteraction.delete(with: ["Order Coffee"], completion: nil)
        //INInteraction.deleteAll(completion: nil)
    }
    
    static func createOrderCoffeeIntent(withCoffee coffee: Coffee) -> OrderCoffeeIntent {
        let intent = OrderCoffeeIntent()
        intent.coffee = INObject(identifier: coffee.rawValue, display: coffee.description)
        let orderString = NSString.deferredLocalizedIntentsString(with: "Order") as String
        intent.suggestedInvocationPhrase = orderString + " " + coffee.description
        //intent.setImage(INImage(named: "IMAGE"), forParameterNamed: \.coffee)
        return intent
    }
    
//    private func userActivity(_ userActivity: NSUserActivity, addImage image: UIImage, subtitle: String) {
//        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
//        attributes.contentDescription = subtitle
//        attributes.thumbnailData = image.pngData()
//        userActivity.contentAttributeSet = attributes
//    }
}
