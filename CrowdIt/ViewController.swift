//
//  ViewController.swift
//  CrowdIt
//
//  Created by Scott Soifer and Ariana Gewurz on 5/25/20.
//  Copyright © 2020 AGS2. All rights reserved.
//
    import UIKit
    import GoogleMaps // add
    import GooglePlaces

class ViewController: UIViewController, GMSMapViewDelegate {
     var placesClient : GMSPlacesClient! // add
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
    }
    
          override func viewDidLoad() {
            super.viewDidLoad() // add
            GMSServices.provideAPIKey("AIzaSyDBEGvuILbEIx4MLupTueP8gcfXFYm0EIo")
            let camera = GMSCameraPosition.camera(withLatitude: 40.807552, longitude: -73.962724, zoom: 10)
            let mapView = GMSMapView.map(withFrame: CGRect.zero,camera: camera)
            view = mapView
            let currentLocation = CLLocationCoordinate2DMake(40.807552, -73.962724)
            if(true){ // if you click on a place
                print("Ariana") // print out the coordinates
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            mapView.delegate = self
            self.view = mapView
            
            let marker = GMSMarker(position: currentLocation)
            marker.title = "Skwl"
            marker.map = mapView
            }
            makeButton()
          }

          // Present the Autocomplete view controller when the button is pressed.
          @objc func autocompleteClicked(_ sender: UIButton) {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self

            // Specify the place data types to return.
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
              UInt(GMSPlaceField.placeID.rawValue))!
            autocompleteController.placeFields = fields

            // Specify a filter.
            let filter = GMSAutocompleteFilter()
            filter.type = .address
            autocompleteController.autocompleteFilter = filter

            // Display the autocomplete view controller.
            present(autocompleteController, animated: true, completion: nil)
          }

          // Add a button to the view.
          func makeButton() {
            let btnLaunchAc = UIButton(frame: CGRect(x: 5, y: 150, width: 300, height: 35))
            btnLaunchAc.backgroundColor = .green
            btnLaunchAc.setTitle("Search for Place", for: .normal)
            btnLaunchAc.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
            self.view.addSubview(btnLaunchAc)
          }

        }

        extension ViewController: GMSAutocompleteViewControllerDelegate {

          // Handle the user's selection.
          func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            print("Place name: \(place.name)")
            print("Place ID: \(place.placeID)")
            print("Place attributions: \(place.attributions)")
            dismiss(animated: true, completion: nil)
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
