//
//  ViewController.swift
//  Codable
//
//  Created by Daniel Klein on 23.11.17.
//  Copyright © 2017 Daniel Klein. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        testAutomatic()
        //testManualMapping()
    }
    
    func testAutomatic() {
        // Encoding
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let anjaComponents = DateComponents(year: 2003, month: 4, day: 1)
        let anjaDate = gregorianCalendar.date(from: anjaComponents)!
        let anjaCar = Car(model: "Golf", make: "VW")
        let anja = Employee(name: "Anja", role: "Head of HR", id: 3, firstDayOfEmployment: anjaDate, gender: .female, car: anjaCar)
        
        let peterComponents = DateComponents(year: 2005, month: 1, day: 1)
        let peterDate = gregorianCalendar.date(from: peterComponents)!
        let peter = Employee(name: "Peter", role: "Janitor", id: 54, firstDayOfEmployment: peterDate, gender: .male, car: nil)
        
        let employees = [anja, peter]
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        jsonEncoder.dateEncodingStrategy = .iso8601
        let data = try! jsonEncoder.encode(employees)
        let jsonString = String(data: data, encoding: .utf8)!
        print(jsonString)
        
        //        let sampleOneURL = Bundle.main.url(forResource: "EmployeeSample1", withExtension: "json")!
        //        let sampleOneData = try! Data(contentsOf: sampleOneURL)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        //        let isoFormatter = DateFormatter()
        //        isoFormatter.dateFormat = "yyyy-MM-dd"
        //        decoder.dateDecodingStrategy = .formatted(isoFormatter)
        
        let decodedEmployees = try! decoder.decode(Array<Employee>.self, from: data)
        print("Done")
    }
    
    func testManualMapping() {
        let sampleURL = Bundle.main.url(forResource: "ManualEmployeeSample", withExtension: "json")!
        let sampleData = try! Data(contentsOf: sampleURL)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedEmployee = try! decoder.decode(Employee.self, from: sampleData)
        print("Done")
    }
}

