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


class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {  // TODO (GMSMapViewDelegate needed?
    
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    let API_Key = "AIzaSyDBEGvuILbEIx4MLupTueP8gcfXFYm0EIo"
    let infoMarker = GMSMarker()
    
    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    var mapView : GMSMapView!
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace){
        
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {}
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.navigationItem.title = "CrowdIt"
        
        
        
        locationManager.requestAlwaysAuthorization()
        placesClient = GMSPlacesClient.shared()
        
        
        GMSServices.provideAPIKey("AIzaSyDBEGvuILbEIx4MLupTueP8gcfXFYm0EIo")
        //
        
        var currentLoc: CLLocation!
        currentLoc = locationManager.location
        let lat = currentLoc.coordinate.latitude
        let lon = currentLoc.coordinate.longitude
        let currLocation = CLLocationCoordinate2DMake(lat, lon)
        
        let camera = GMSCameraPosition.camera(withTarget: currLocation, zoom: 12)
        mapView = GMSMapView.map(withFrame: CGRect.zero,camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        view = mapView
        
    }
    
    // when you tap on store on map
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
        
        
        NetworkUtility.shared.sendGetReq(place_id: placeID) { (jsonRes, error) in
            DispatchQueue.main.async {
                let placeDet = placeDetails(numPpl: jsonRes, placeName: name)
                self.setMarker(location: location, placeDet: placeDet)
//                self.infoMarker.snippet = "There are currently \(placeDet.numPpl) people in \(placeDet.placeName)"
//                self.infoMarker.position = location
//                self.infoMarker.title = "\(placeDet.numPpl) people here"
//                self.infoMarker.opacity = 0;
//                self.infoMarker.map = mapView
//                self.mapView.selectedMarker = self.infoMarker
                
                //                let alert = UIAlertController(title: "\(jsonRes) people here", message: "There are currently \(jsonRes) people in \(String(describing: place.name ?? "" ))", preferredStyle: UIAlertController.Style.alert)
                //                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                //                self.present(alert, animated: true, completion: nil)
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
    func setMarker(location: CLLocationCoordinate2D, placeDet : placeDetails){

            mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom: 17)

            infoMarker.snippet = "There are currently \(placeDet.numPpl) people in \(placeDet.placeName)"
            infoMarker.position = location
            infoMarker.title = "\(placeDet.numPpl) people here"

            infoMarker.opacity = 0;
            infoMarker.map = mapView
            mapView.selectedMarker = infoMarker
            
            
        }
        
        @objc func autocomplete( ) {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self as? GMSAutocompleteViewControllerDelegate
            
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
            
            // Specify a filter.
            let filter = GMSAutocompleteFilter()
            //                filter.type = .address
            filter.type = .establishment
            autocompleteController.autocompleteFilter = filter
            
            // Display the autocomplete view controller.
            present(autocompleteController, animated: true, completion: nil)
        }
        
      
        
        
        
        
        @IBAction func postButton(_ sender: UIButton) {
            
            // Encapsulated network calls as new object
            NetworkUtility.shared.placesAPITest()
            //        NetworkUtility.shared.googlePlacesVersion()
            
            
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
            print(place.name ?? "", place.placeID ?? "", place.coordinate ?? "")
            
            dismiss(animated: true, completion: nil)
            NetworkUtility.shared.sendGetReq(place_id: String(describing: place.placeID ?? "" )) { (jsonRes, error) in
                DispatchQueue.main.async {
                    let placeDet = placeDetails(numPpl: jsonRes, placeName: String(describing: place.name ?? "" ))
                    self.setMarker(location: place.coordinate, placeDet: placeDet)
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
