//
//  ViewController.swift
//  MeasurementAPI
//
//  Created by Daniel Klein on 18.02.18.
//  Copyright © 2018 Daniel Klein. All rights reserved.
//

import UIKit

extension UnitLength {
    static let nose = UnitLength(symbol: "nose", converter: UnitConverterLinear(coefficient: 3.7/100))
}

class UnitGamePoints: Dimension {
    static let points = UnitGamePoints(symbol: "points", converter: UnitConverterLinear(coefficient: 1))
    static let bonus = UnitGamePoints(symbol: "bonus", converter: UnitConverterLinear(coefficient: 10))
    static let megaBonus = UnitGamePoints(symbol: "mega bonus", converter: UnitConverterLinear(coefficient: 100))
    
    override static func baseUnit() -> UnitGamePoints {
        return points
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let someActivity: (Timer) -> Void = {_ in }
        let timer = Timer(timeInterval: 5.0, repeats: false, block: someActivity)
        let interval = 5*60*60
        
        let metersConverter = UnitConverterLinear(coefficient: 1)
        let meters = UnitLength(symbol: "m", converter: metersConverter)
        let kilometers = UnitLength(symbol: "km", converter: UnitConverterLinear(coefficient: 1000, constant: 0))
        let centimeters = UnitLength(symbol: "cm", converter: UnitConverterLinear(coefficient: 1/100))

        let distance = Measurement<UnitLength>(value: 5.0, unit: .kilometers)
        let anotherDistance = Measurement(value: 1.0, unit: UnitLength.kilometers)

        print("Distance one: \(distance) two: \(anotherDistance)")

        if distance > anotherDistance {
            let a = distance + anotherDistance
            let b = 3 * a
            let c = 1 / b
            //let d = a / b // error!
            
            let resultInCentimeters = c.converted(to: .centimeters)
            let rawValueInCentimeters = resultInCentimeters.value
            
        }

        // Formatting
        let speedFormatter = MeasurementFormatter()
        speedFormatter.locale = Locale(identifier: "de")
        speedFormatter.unitStyle = .medium

        let speed = Measurement<UnitSpeed>(value: 100, unit: .kilometersPerHour)
        let localizedSpeed = speedFormatter.string(from: speed)
        print("Speed is: \(localizedSpeed)")
        
        speedFormatter.unitStyle = .short
        print("Unit Style Short: \(speedFormatter.string(from: speed))")
        
        speedFormatter.unitStyle = .medium
        print("Unit Style Medium: \(speedFormatter.string(from: speed))")
        
        speedFormatter.unitStyle = .long
        print("Unit Style Long: \(speedFormatter.string(from: speed))")
        
        let distanceToSun = Measurement<UnitLength>(value: 1, unit: .astronomicalUnits)
        print("Distance to sun: \(distanceToSun)")
        
        let sunFormatter = MeasurementFormatter()
        sunFormatter.unitStyle = .long
        let defaultFormatting = sunFormatter.string(from: distanceToSun)
        print("Default: \(defaultFormatting)")

        sunFormatter.unitOptions = .providedUnit
        let providedFormat = sunFormatter.string(from: distanceToSun)
        print("Provided: \(providedFormat)")

        sunFormatter.unitOptions = .naturalScale // -> Default?
        let naturalFormat = sunFormatter.string(from: distanceToSun)
        print("Natural: \(naturalFormat)")

        // Translate just the unit
        let weightFormatter = MeasurementFormatter()
        weightFormatter.locale = Locale(identifier: "it")
        weightFormatter.unitStyle = .long
        let localizedWeight = weightFormatter.string(from: UnitMass.kilograms)
        print("Localized Weight: \(localizedWeight)")
        
        
        // Settable NumberFormatter
        sunFormatter.unitOptions = []

        let roundingFormatter = NumberFormatter()
        roundingFormatter.numberStyle = .decimal
        roundingFormatter.minimumFractionDigits = 0
        roundingFormatter.maximumFractionDigits = 0
        sunFormatter.numberFormatter = roundingFormatter

        let roundedSunDistance = sunFormatter.string(from: distanceToSun)
        print("Rounded distance to sun: \(roundedSunDistance)")

        // Recognizing unit strings... Not possible! No "backwards formatter"...
        let speeed = Measurement<UnitSpeed>(value: 130, unit: .kilometersPerHour)
        
        // Eine Nasenlänge voraus! :-)
        // 1 nose is 3,7 cm
        let noseUnit = UnitLength(symbol: "nose", converter: UnitConverterLinear(coefficient: 3.7/100))

        let oneNose = Measurement<UnitLength>(value: 1, unit: .nose)
        let noseInCentimeters = oneNose.converted(to: .centimeters)
        
        print("One nose ahead is \(noseInCentimeters)")
        
        // Creating a custom Dimension subclass
        var points = Measurement<UnitGamePoints>(value: 40, unit: .points)
        points = points + Measurement<UnitGamePoints>(value: 3, unit: .bonus)
        points = points + Measurement<UnitGamePoints>(value: 1, unit: .megaBonus)
        print("Game Over! You have \(points). Congratulations!")

        // This would be nice to have. Unfortunately we don't...
        // let delay = Measurement<UnitDuration>(value: 5, unit: .hours)
        // let timer = Timer(timeInterval: delay, repeats: false, block: someActivity)
    }
}
