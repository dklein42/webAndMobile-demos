//
//  ModelDemoViewController.swift
//  DragAndDropTest
//
//  Created by Daniel Klein on 25.07.17.
//  Copyright © 2017 House of Bytes Software. All rights reserved.
//

import UIKit
import MobileCoreServices

enum ParseError: Error {
    case decodingFailed(String)
}

class Product: NSObject, NSItemProviderReading, NSItemProviderWriting, Codable {
    static let typeIdentifier = "com.example.Product"
    
    let name: String
    let category: String
    let price: Double
    
    init(name: String, category: String, price: Double) {
        self.name = name
        self.category = category
        self.price = price
        super.init()
    }
    
    // MARK: Reading
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [Product.typeIdentifier]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        switch typeIdentifier  {
        case Product.typeIdentifier:
            return try! JSONDecoder().decode(self, from: data)
        default:
            throw ParseError.decodingFailed("Invalid type!")
        }
    }

    // Deprecated? This is supposed not to be required anymore, I guess...
    required init(itemProviderData data: Data, typeIdentifier: String) throws {
        if typeIdentifier == Product.typeIdentifier {
            let product = try? JSONDecoder().decode(Product.self, from: data)

            if let p = product {
                self.name = p.name
                self.category = p.category
                self.price = p.price
                return
            }
        }

        throw ParseError.decodingFailed("Invalid type!")
    }

    // MARK: Writing
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [Product.typeIdentifier, kUTTypeUTF8PlainText as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let data: Data?
        
        switch typeIdentifier {
        case Product.typeIdentifier:
            data = try? JSONEncoder().encode(self)
        case kUTTypeUTF8PlainText as NSString as String:
            data = "\(name), \(category), \(price)".data(using: .utf8)
        default:
            data = nil
        }
        
        completionHandler(data, nil)
        return nil
    }
}

