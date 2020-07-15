//
//  ViewController.swift
//  CrowdIt
//
//  Created by Ariana Gewurz and Scott Soifer on 5/25/20.
//  Copyright © 2020 AGS2. All rights reserved.
//

import UIKit
import GoogleMaps
//import Alamofire
import GooglePlaces
import CoreLocation

struct placeDetails {
    var numPpl: String
    var placeName : String
}
struct API_KEY {
    static let key: String = ProcessInfo.processInfo.environment["DEBUGMODE"] ?? ""
//    static let key: String = "ABCD"
}


class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {  // TODO (GMSMapViewDelegate needed?
    
    var placesClient: GMSPlacesClient!
    var locationManager : CLLocationManager!
    let infoMarker = GMSMarker()
    var timer = Timer()
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var switch1: UISwitch!
    
    
    var mapView : GMSMapView!
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace){
        
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var currentLoc: CLLocation!
        var camera: GMSCameraPosition
        var lat = 0.0
        var lon = 0.0
        
        print("Dev id: \(UIDevice.current.identifierForVendor?.uuidString ?? "0")")
        
        switch1.isOn = userDefaults.bool(forKey: "switchValue")
        
        placesClient = GMSPlacesClient.shared()
        // ProcessInfo.processInfo.environment["DEBUGMODE"] ?? ""
        GMSServices.provideAPIKey(API_KEY.key)
        
        //        scheduledTimer()   // sends post request with current location at interval
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        locationManager.distanceFilter = 30
        locationManager.startUpdatingLocation()
        //        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = userDefaults.bool(forKey: "switchValue") ? true : false
        locationManager.pausesLocationUpdatesAutomatically = false
        
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways && locationManager.location != nil) {
            currentLoc = locationManager.location
            lat = currentLoc.coordinate.latitude
            lon = currentLoc.coordinate.longitude
            
            let currLocation = CLLocationCoordinate2DMake(lat, lon)
            currentLoc = locationManager.location
            camera = GMSCameraPosition.camera(withTarget: currLocation, zoom: 12)
        }
        else{
            camera = GMSCameraPosition.camera(withLatitude: 40.807552, longitude: -73.962724, zoom: 12)
        }
        mapView = GMSMapView.map(withFrame: CGRect.zero,camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        view = mapView
        
    }
    // updates location in background
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            NetworkUtility.shared.placesAPI()
            print("New location is \(location)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status != CLAuthorizationStatus.authorizedAlways) {
            switch1.isOn = false
            userDefaults.set(false, forKey: "switchValue")
        }
        else {
            switch1.isOn = true
            userDefaults.set(true, forKey: "switchValue")
        }
    }
    
    func scheduledTimer(){  // sends post request with current location at 15 minute  interval
        timer = Timer.scheduledTimer(timeInterval: 900, target: NetworkUtility(), selector: #selector(NetworkUtility.shared.placesAPI), userInfo: nil, repeats: true)
    }
    
    // when you tap on store on map
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
        
        
        NetworkUtility.shared.sendGetReq(place_id: placeID) { (jsonRes, error) in
            DispatchQueue.main.async {
                let placeDet = placeDetails(numPpl: jsonRes, placeName: name)
                self.setMarker(location: location, placeDet: placeDet, zoom: false)
                
            }
        }
        
        
    }
    //    Add a button to the view.
    //                       func makeButton() {
    //                         let btnLaunchAc = UIButton(frame: CGRect(x: 5, y: 150, width: 300, height: 35))
    //                         btnLaunchAc.backgroundColor = .green
    //                         btnLaunchAc.setTitle("Search for Place", for: .normal)
    //                         btnLaunchAc.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
    //                         self.view.addSubview(btnLaunchAc)
    //                       }
    
    // here ariana this is for you
    // for search bar
    func setMarker(location: CLLocationCoordinate2D, placeDet : placeDetails, zoom : Bool){
        if(zoom){
            // moves marker to current place location
            // disabled for marker tap function
            mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom: 17)
        }
        infoMarker.snippet = "There \(placeDet.numPpl == "1" ? "is" : "are") currently \(placeDet.numPpl) \(placeDet.numPpl == "1" ? "person" : "people") in \(placeDet.placeName)"
        infoMarker.position = location
        infoMarker.title = "\(placeDet.numPpl) \(placeDet.numPpl == "1" ? "person" : "people") here"
        
        infoMarker.opacity = 0;
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
        
        
    }
    
    @objc func autocomplete( ) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
        
        // dark mode check
        switch UITraitCollection.current.userInterfaceStyle  {
        case .dark:
            autocompleteController.primaryTextColor = UIColor.white
            autocompleteController.secondaryTextColor = UIColor.lightGray
            autocompleteController.tableCellSeparatorColor = UIColor.lightGray
            autocompleteController.tableCellBackgroundColor = UIColor.darkGray
        default:
            autocompleteController.primaryTextColor = UIColor.black
            autocompleteController.secondaryTextColor = UIColor.lightGray
            autocompleteController.tableCellSeparatorColor = UIColor.lightGray
            autocompleteController.tableCellBackgroundColor = UIColor.white
        }
        
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) )!
        autocompleteController.placeFields = fields
        
        let filter = GMSAutocompleteFilter()
        //                filter.type = .address
        filter.type = .establishment
        autocompleteController.autocompleteFilter = filter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func togglePost(_ sender: Any) {
        userDefaults.set((sender as AnyObject).isOn, forKey: "switchValue")
        if(switch1.isOn){
            if (CLLocationManager.authorizationStatus() != .authorizedAlways) {
                let alertController = UIAlertController(title: "Background Location Not Enabled", message: "Go to Settings to allow location in background", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                self.present(alertController, animated: true, completion: nil)
            }
            NetworkUtility.shared.placesAPI()
            let alert = UIAlertController(title: "Thanks for sharing your location in background", message: "You are helping other CrowdIt know how busy stores are", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.locationManager.allowsBackgroundLocationUpdates =  true
        }
        if(!switch1.isOn) {
            self.locationManager.allowsBackgroundLocationUpdates = false
        }
        
    }
    
    
    
    @IBAction func searchButton(_ sender: Any) {
        
        autocomplete()
        
    }
    
    
    
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //    print("Place name: \(place.name)")
        //    print("Place ID: \(place.placeID)")
        //    print("Place attributions: \(place.attributions)")
        print(place.name ?? "", place.placeID ?? "", place.coordinate )
        
        dismiss(animated: true, completion: nil)
        NetworkUtility.shared.sendGetReq(place_id: String(describing: place.placeID ?? "" )) { (jsonRes, error) in
            DispatchQueue.main.async {
                let placeDet = placeDetails(numPpl: jsonRes, placeName: String(describing: place.name ?? "" ))
                self.setMarker(location: place.coordinate, placeDet: placeDet, zoom: true)
                //                let alert = UIAlertController(title: "\(jsonRes) people here", message: "There are currently \(jsonRes) people in \(String(describing: place.name ?? "" ))", preferredStyle: UIAlertController.Style.alert)
                //                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                //                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
