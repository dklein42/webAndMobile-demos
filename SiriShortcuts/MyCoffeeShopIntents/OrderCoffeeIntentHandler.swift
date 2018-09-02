//
//  OrderCoffeeIntentHandler.swift
//  SiriShortcuts
//
//  Created by Daniel Klein on 22.08.18.
//  Copyright © 2018 Daniel Klein. All rights reserved.
//

import UIKit
import Intents

class OrderCoffeeIntentHandler: NSObject, OrderCoffeeIntentHandling {
    var isStoreClosed: Bool = false

    func confirm(intent: OrderCoffeeIntent, completion: @escaping (OrderCoffeeIntentResponse) -> Void) {
        // Check order...
        
        if isStoreClosed {
            completion(OrderCoffeeIntentResponse(code: .storeClosed, userActivity: nil))
            return
        }
        
        completion(OrderCoffeeIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: OrderCoffeeIntent, completion: @escaping (OrderCoffeeIntentResponse) -> Void) {
        // Perform order...
        
        let response = OrderCoffeeIntentResponse(code: .success, userActivity: nil)
        response.coffee = intent.coffee
        response.waitTime = 10
        
        completion(response)
    }
}
