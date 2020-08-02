//
//  ViewController.swift
//  ReducedAccuracy
//
//  Created by Daniel Klein on 27.07.20.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Necessary?
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location services not enabled!")
            return
        }
        
        locationManager.delegate = self
        
//        let currentAuthStatus = locationManager.authorizationStatus()
//        let currentAuthLevel = locationManager.accuracyAuthorization
//        print("Current auth status is: \(currentAuthStatus)")
//        print("Current auth level is: \(currentAuthLevel)")
                
        // Explicitly request reduced accuracy (or entry in Info.plist)
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        
        //locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
    }
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch locationManager.authorizationStatus() {
//        case .notDetermined:
//            print("Not Determined")
//        case .restricted:
//            print("Restricted")
//        case .denied:
//            print("Denied")
//        case .authorizedAlways:
//            print("Authorized Always")
//            locationManager.startUpdatingLocation()
//        case .authorizedWhenInUse:
//            print("Authorized When in Use")
//            locationManager.startUpdatingLocation()
//        @unknown default:
//            fatalError("This should not happen!")
//        }
//
//        switch locationManager.accuracyAuthorization {
//        case .fullAccuracy:
//            print("Full Accuracy")
//        case .reducedAccuracy:
//            print("Reduced Accuracy")
//        @unknown default:
//            fatalError("This should not happen!")
//        }
//    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            print("Not Authorized")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized")

            switch locationManager.accuracyAuthorization {
            case .fullAccuracy:
                print("Full Accuracy")
            case .reducedAccuracy:
                print("Reduced Accuracy")
            @unknown default:
                fatalError("This should not happen!")
            }

            locationManager.startUpdatingLocation()
            locationManager.startMonitoringVisits()
            locationManager.startMonitoringSignificantLocationChanges()
            
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: +50.54711157, longitude: +7.12660069), radius: manager.maximumRegionMonitoringDistance, identifier: "My Test 1")
            locationManager.startMonitoring(for: region)
            
            let monitoredRegions = locationManager.monitoredRegions
            print("Monitored regions are: \(monitoredRegions)")
            
        @unknown default:
            fatalError("This should not happen!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Locations received: \(locations)")
    }

    @IBAction func requestTemporaryFullAccuracy() {
        //locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        guard locationManager.accuracyAuthorization == .reducedAccuracy else {
            print("Already at full accuracy. No need to request temp.")
            return
        }
        
        print("Requesting temporary full accuracy")
        
        locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "WantsToNavigate") { error in
            if error == nil {
                print("Temporary full accuracy granted!")
                return
            }

            // User denied
            if let error = error as? CLError {
                if case error.code = CLError.Code.promptDeclined {
                    // The only returned error
                    print("Temporary full accuracy denied!")
                    
                    // Caution! May also fail if already ALLOWED!
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("Did visit: \(visit)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Did enter region: \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Did exit region: \(region)")
    }
}

