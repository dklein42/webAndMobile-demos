//
//  ManualEmployee.swift
//  Codable
//
//  Created by Daniel Klein on 28.11.17.
//  Copyright © 2017 Daniel Klein. All rights reserved.
//

import Foundation

struct Employee: Codable {
    let name: String
    let role: String
    let id: Int
    let firstDayOfEmployment: Date
    let gender: Gender
    let car: Car?
    
    init(name: String, role: String, id: Int, firstDayOfEmployment: Date, gender: Gender, car: Car?) {
        self.name = name
        self.role = role
        self.id = id
        self.firstDayOfEmployment = firstDayOfEmployment
        self.gender = gender
        self.car = car
    }
    
    init(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        role = try container.decode(String.self, forKey: .role)
        id = try container.decode(Int.self, forKey: .id)
        firstDayOfEmployment = try container.decode(Date.self, forKey: .firstDayOfEmployment)
        gender = try container.decode(Gender.self, forKey: .gender)
        car = try container.decodeIfPresent(Car.self, forKey: .car)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(role, forKey: .role)
        try container.encode(id, forKey: .id)
        try container.encode(firstDayOfEmployment, forKey: .firstDayOfEmployment)
        try container.encode(gender, forKey: .gender)
        try container.encodeIfPresent(car, forKey: .car)
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "full_name"
        case role = "company_role"
        case id = "employee_number"
        case firstDayOfEmployment = "started"
        case gender
        case car
    }
}

enum Gender: String, Codable {
    case male = "m"
    case female = "f"
    case other = "o"
}

struct Car: Codable {
    let model: String
    let make: String
}
