//
//  ViewController.swift
//  mapSchool
//
//  Created by Alex Arovas on 10/25/16.
//  Copyright © 2016 Alex Arovas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var map: MKMapView!
    var manager: CLLocationManager!
    
    var latLong: UILabel!
    var location: UILabel!
    
    var mapType: UISegmentedControl!
    var TrackingType: UISegmentedControl!
    
    var userLocation: CLLocation!
    
    var Address: String!
    
    var first: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        map = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 2/3 * self.view.frame.height))
        map.delegate = self
        map.showsUserLocation = true
        map.centerCoordinate = map.userLocation.coordinate
        map.mapType = .hybridFlyover
        map.showsBuildings = true
        map.showsScale = true
        map.showsTraffic = false
        map.userTrackingMode = .none
        
        latLong = UILabel(frame: CGRect(x: 0, y: 2/3 * self.view.frame.height - 5, width: self.view.frame.width, height: 120))
        latLong.textAlignment = .center
        latLong.numberOfLines = 6
        latLong.lineBreakMode = .byWordWrapping
        latLong.shadowOffset = CGSize(width: 5, height: -5)
        latLong.textColor = .cyan
        latLong.font = UIFont(name: "Cochin-BoldItalic", size: 16)

        location = UILabel(frame:CGRect(x: 0, y: 2/3 * self.view.frame.height + 80, width: self.view.frame.width, height: 120))
        location.textAlignment = .center
        location.numberOfLines = 6
        location.lineBreakMode = .byWordWrapping
        location.shadowOffset = CGSize(width: 5, height: -5)
        location.textColor = .red
        location.font = UIFont(name: "Chalkduster", size: 14)
        
        mapType = UISegmentedControl(items: ["Satilite", "Hybrid", "Standard"])
        mapType.frame = CGRect(x: 30, y: 2/3 * self.view.frame.height - 80, width: self.view.frame.width - 60, height: 25)
        mapType.backgroundColor = .clear
        mapType.tintColor = .orange
        mapType.selectedSegmentIndex = 1
        mapType.addTarget(self, action: #selector(self.mapTypeChanged), for: .valueChanged)
        
        TrackingType = UISegmentedControl(items: ["Heading", "Follow", "None"])
        TrackingType.frame = CGRect(x: 30, y: 2/3 * self.view.frame.height - 45, width: self.view.frame.width - 60, height: 25)
        TrackingType.backgroundColor = .clear
        TrackingType.tintColor = .magenta
        TrackingType.selectedSegmentIndex = 2
        TrackingType.addTarget(self, action: #selector(self.trackTypeChanged), for: .valueChanged)

        
        if map.userLocation.location != nil {
            
            userLocation = map.userLocation.location as CLLocation!
            
            var nOrS = "S"
            var eOrW = "W"
            var nSEOrW = "N"
            
            if userLocation.coordinate.latitude > 0 {
                nOrS = "N"
            }
            
            if userLocation.coordinate.longitude > 0 {
                eOrW = "E"
            }
            
            if userLocation.course >= 45 && userLocation.course < 135 {
                nSEOrW = "E"
            } else if userLocation.course >= 135 && userLocation.course < 225 {
                nSEOrW = "S"
            } else if userLocation.course >= 225 && userLocation.course < 315 {
                nSEOrW = "W"
            }
            
            let format = DateFormatter()
            
            format.dateStyle = .medium
            format.timeStyle = .long
            
            let lat = "Lat: \(userLocation.coordinate.latitude)°\(nOrS),  "
            let long = "Long: \(userLocation.coordinate.longitude)°\(eOrW),  "
            let alt = "Alt: \(userLocation.altitude)M,  "
            let locAcc = "Loc Acc: +/- \(userLocation.horizontalAccuracy)M,  "
            let altAcc = "Alt Acc: +/- \(userLocation.verticalAccuracy)M,  "
            let speed = "Speed: \(userLocation.speed)M/S,  "
            let course = "Course: \(userLocation.course)° \(nSEOrW),  "
            let date = "Date: \(format.string(from: userLocation.timestamp))"
            
            latLong.text = lat + long + alt + locAcc + altAcc + speed + course + date
        
            location.text = Address
            
            map.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
            
            first = !first
        }
        self.view.addSubview(map)
        self.view.addSubview(latLong)
        self.view.addSubview(location)
        self.view.addSubview(mapType)
        self.view.addSubview(TrackingType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapTypeChanged(sender: UISegmentedControl) {
        switch mapType.selectedSegmentIndex {
        case 0:
            map.mapType = .satelliteFlyover
        case 1:
            map.mapType = .hybridFlyover
        default:
            map.mapType = .standard
        }
    }
    
    func trackTypeChanged(sender: UISegmentedControl) {
        switch TrackingType.selectedSegmentIndex {
        case 0:
            map.userTrackingMode = .followWithHeading
        case 1:
            map.userTrackingMode = .follow
        default:
            map.userTrackingMode = .none
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location1 = locations.first {
            userLocation = location1
            
            self.reverseGeocoding(CLLocationDegrees(location1.coordinate.latitude), longitude: CLLocationDegrees(location1.coordinate.longitude))
            
            var nOrS = "S"
            var eOrW = "W"
            var nSEOrW = "N"
            
            if userLocation.coordinate.latitude > 0 {
                nOrS = "N"
            }
            
            if userLocation.coordinate.longitude > 0 {
                eOrW = "E"
            }
            
            if userLocation.course >= 45 && userLocation.course < 135 {
                nSEOrW = "E"
            } else if userLocation.course >= 135 && userLocation.course < 225 {
                nSEOrW = "S"
            } else if userLocation.course >= 225 && userLocation.course < 315 {
                nSEOrW = "W"
            }
            
            let format = DateFormatter()
            
            format.dateStyle = .medium
            format.timeStyle = .long
            
            let lat = "Lat: \(userLocation.coordinate.latitude)°\(nOrS),  "
            let long = "Long: \(userLocation.coordinate.longitude)°\(eOrW),  "
            let alt = "Alt: \(userLocation.altitude)M,  "
            let locAcc = "Loc Acc: +/- \(userLocation.horizontalAccuracy)M,  "
            let altAcc = "Alt Acc: +/- \(userLocation.verticalAccuracy)M,  "
            let speed = "Speed: \(userLocation.speed)M/S,  "
            let course = "Course: \(userLocation.course)° \(nSEOrW),  "
            let date = "Date: \(format.string(from: userLocation.timestamp))"
            
            latLong.text = lat + long + alt + locAcc + altAcc + speed + course + date
            
            location.text = Address
            
            if first {
                map.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
                first = !first
                print("HERERERE")
            }
        }
    }
    
    func postalAddressFromAddressDictionary(_ addressdictionary: NSDictionary) -> CNMutablePostalAddress {
        
        let address = CNMutablePostalAddress()
        
        address.street = addressdictionary["Street"] as? String ?? ""
        address.state = addressdictionary["State"] as? String ?? ""
        address.city = addressdictionary["City"] as? String ?? ""
        address.country = addressdictionary["Country"] as? String ?? ""
        address.postalCode = addressdictionary["ZIP"] as? String ?? ""
        
        return address
    }
    
    func reverseGeocoding(_ latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            else if placemarks!.count > 0 {
                let pm = placemarks![0]
                let address = CNPostalAddressFormatter.string(from: self.postalAddressFromAddressDictionary(pm.addressDictionary! as NSDictionary), style: .mailingAddress)
                self.Address = address
                if pm.areasOfInterest != nil && pm.areasOfInterest!.count > 0 {
                    let areaOfInterest = pm.areasOfInterest?[0]
                    self.Address = "Address: \(self.Address as String) Area: \(areaOfInterest!)"
                } else {
                    print("No area of interest found.")
                }
            }
        })
    }


}

