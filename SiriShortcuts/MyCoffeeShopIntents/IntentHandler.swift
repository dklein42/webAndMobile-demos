//
//  IntentHandler.swift
//  MyCoffeeShopIntents
//
//  Created by Daniel Klein on 23.08.18.
//  Copyright © 2018 Daniel Klein. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is OrderCoffeeIntent else {
            fatalError("Unknown intent: \(intent)")
        }
        
        return OrderCoffeeIntentHandler()
    }
    
}
