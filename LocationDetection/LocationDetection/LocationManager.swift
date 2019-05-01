//
//  LocationManager.swift
//  LocationDetection
//
//  Created by Daniel Klein on 08.04.19.
//  Copyright © 2019 House of Bytes. All rights reserved.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
	static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        guard CLLocationManager.locationServicesEnabled() else {
            // Location services not available... (maybe disabled...)
            return
        }
        
//        CLLocationManager.deferredLocationUpdatesAvailable()
//        CLLocationManager.significantLocationChangeMonitoringAvailable()
        
        locationManager.delegate = self
        
        // Authorization
        
        // Setup string in Info.plist, enable Switch in target settings
        
        //locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // Single request, provided to the delegate
        locationManager.requestLocation()
        
        // Most recent location, may be nil
        let recentLocation = locationManager.location
        print("Cached location is: \(String(describing: recentLocation))")
        
        startLocationUpdates()
    }
    
    private func startLocationUpdates() {
        // Default is Best! kCLLocationAccuracyBest
        //locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        //locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.startUpdatingLocation()
        
//        guard CLLocationManager.significantLocationChangeMonitoringAvailable() else {
//            // Significant location changes not available...
//            return
//        }
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startMonitoringVisits()
        
        let center = CLLocationCoordinate2D(latitude: 50.941319, longitude: 6.958210)
        let region = CLCircularRegion(center: center, radius: 100, identifier: "Kölner Dom")
        locationManager.startMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // Initial state, automatically request when-in-use
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Disable location features
            break
        case .authorizedWhenInUse:
            // Enable features for when-in-use
            break
        case .authorizedAlways:
            // Enable always features
            break
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("New locations received: \(locations)")
        print("Newest is: \(locations.last!)")
        
        let coordinate = locations.last!.coordinate
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        print("Lat: \(latitude) Lon: \(longitude)")
        
        print("Floor: \(String(describing: locations.last!.floor))")
        
        let a = locations.first!
        let b = locations.last!
        let distance = a.distance(from: b)
        print("Distance is: \(distance)m")
    }
    
//    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("New heading received: \(newHeading)")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed with error: \(error)")
        
        let nsError = error as NSError
        
        if nsError.code == CLError.Code.locationUnknown.rawValue {
            print("Getting location failed!")
        }
        
        if nsError.code == CLError.Code.denied.rawValue {
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.stopMonitoringVisits()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("Failed with error: \(String(describing: error))")
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("New visit received: \(visit)")
        _ = Date.distantFuture == Date.distantPast
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Did enter region: \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Did exit region: \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring did fail for region: \(String(describing: region))")
    }
}
