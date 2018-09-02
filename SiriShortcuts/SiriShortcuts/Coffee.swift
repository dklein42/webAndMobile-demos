//
//  Coffee.swift
//  SiriShortcuts
//
//  Created by Daniel Klein on 22.08.18.
//  Copyright © 2018 Daniel Klein. All rights reserved.
//

import UIKit

enum Coffee: String, CustomStringConvertible, CaseIterable {
    case espresso
    case espressoDopio
    case caffeLatte
    case cappuccino
    case americano

    var description: String {
        switch self {
        case .espresso: return "Espresso"
        case .espressoDopio: return "Espresso Doppio"
        case .caffeLatte: return "Caffè Latte"
        case .cappuccino: return "Cappuccino"
        case .americano: return "Caffè Americano"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .espresso: return "Yummy Espresso"
        case .espressoDopio: return "Twice the coffee, twice the fun!"
        case .caffeLatte: return "Have it with milk!"
        case .cappuccino: return "Another milky joy."
        case .americano: return "Thin and I like it."
        }
    }
}
