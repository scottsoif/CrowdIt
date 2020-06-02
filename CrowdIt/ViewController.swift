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


class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {  // TODO (GMSMapViewDelegate needed?

    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    let API_Key = ProcessInfo.processInfo.environment["DEBUGMODE"] ?? ""

    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace){
        
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {}
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "CrowdIt"
        locationManager.requestAlwaysAuthorization()
        placesClient = GMSPlacesClient.shared()
        
        GMSServices.provideAPIKey(ProcessInfo.processInfo.environment["DEBUGMODE"] ?? "")
//
          let camera = GMSCameraPosition.camera(withLatitude: 40.807552, longitude: -73.962724, zoom: 10)
          let mapView = GMSMapView.map(withFrame: CGRect.zero,camera: camera)
          view = mapView
          let currentLocation = CLLocationCoordinate2DMake(40.807552, -73.962724)
          if(true){ // if you click on a place
          let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            mapView.delegate = self as? GMSMapViewDelegate
          self.view = mapView

          let marker = GMSMarker(position: currentLocation)
          marker.title = "Skwl"
          marker.map = mapView
          }
//          makeButton()
        }
    
//              @objc func autocompleteClicked(_ sender: UIButton) {
            @objc func autocomplete( ) {
                let autocompleteController = GMSAutocompleteViewController()
                autocompleteController.delegate = self as? GMSAutocompleteViewControllerDelegate

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
//              func makeButton() {
//                let btnLaunchAc = UIButton(frame: CGRect(x: 5, y: 150, width: 300, height: 35))
//                btnLaunchAc.backgroundColor = .green
//                btnLaunchAc.setTitle("Search for Place", for: .normal)
//                btnLaunchAc.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
//                self.view.addSubview(btnLaunchAc)
//              }


            


    
    
    func googlePlacesVersion(){
        // G maps
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))!
        placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
          (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }

          if let placeLikelihoodList = placeLikelihoodList {
            for likelihood in placeLikelihoodList {
              let place = likelihood.place
              print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
              print("Current PlaceID \(String(describing: place.placeID))")
             print("Current Address \(String(describing: place.addressComponents))")
                print("Current Place ** \(String(describing: likelihood))")
            }
          }
        })
    }
    
    
    @IBAction func postButton(_ sender: UIButton) {

        placesAPITest()
//        googlePlacesVersion()
 
    
    }
    @IBAction func getButton(_ sender: Any) {
        print("yessir")
        autocomplete()
        sendGetReq(place_id: "ChIJHWeDu_FlwokRRvHnCSXZL_w") { (jsonRes, error) in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "There are \(jsonRes) people here", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    func placesAPITest( ) {
        var currentLoc: CLLocation!
        currentLoc = locationManager.location
        let lat = currentLoc.coordinate.latitude
        let lon = currentLoc.coordinate.longitude
        
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lon)&radius=35&key=\(API_Key)") else { return }
        print("Maps URL:   \(url)")
//        print("Current loc: \(locationManager.location)")
//        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.620865,-73.725636&radius=35&key=\(API_Key)") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
//                guard let httpBody = try? JSONSerialization.data(withJSONObject: paramaters, options: []) else { return }
//                request.httpBody = httpBody
                let session = URLSession.shared
                session.dataTask(with: request) { (data, response, error) in
                    if let response = response{
                        // gets status code
                        if let httpResponse = response as? HTTPURLResponse {
                            print("statusCode: \(httpResponse.statusCode)")
                        }
                    }
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options:[]) as! NSDictionary
                            let results = json["results"] as! [NSDictionary]
                            var place_ids_names = [[String]]()
                            for place in results {
//                                print(place["name"] ?? "", place["place_id"] ?? "")
                                let place_id  =  String(describing: place["place_id"] ?? "" )
                                let place_name  =  String(describing: place["name"] ?? "" )
                                
                                place_ids_names.append([place_id, place_name])
                            }
                            self.sendPost(place_id: place_ids_names)
                            print("Place IDs  \(place_ids_names)")
                            print("Success data")
                        } catch {
                            print(error)
                        }
                    }
                }.resume()
        
     }
    
    
    func sendPost(place_id : Any){
        let paramaters = ["userid":"13", "zipcode":"11559",  "placeid":place_id]
                guard let url = URL(string: "http://24.44.193.13:60/posts") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                guard let httpBody = try? JSONSerialization.data(withJSONObject: paramaters, options: []) else { return }
                request.httpBody = httpBody
                print("Post URL:   \(url)")
                let session = URLSession.shared
                session.dataTask(with: request) { (data, response, error) in
                    if let response = response{
                        // gets status code
                        if let httpResponse = response as? HTTPURLResponse {
                            print("statusCode: \(httpResponse.statusCode)")
                        }
                    }
                }.resume()    }


    func sendGetReq(place_id : String, completionHandler:@escaping(String, Error?)->Void){
//        var tally : Any = 0
        guard let url = URL(string: "http://24.44.193.13:60/?placeid=\(place_id)") else { return }
        print("Get URL:   \(url)")
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let response = response{
                // gets status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("statusCode: \(httpResponse.statusCode)")
                }
            }
            if let data = data {

                do {
                    let json = try JSONSerialization.jsonObject(with: data , options: [])
                    
//                    print(type(of: json))
//                    print(json)
//                    var tally: Any = 0
                    if let res = json as? [[String:Any]]{
                    let tally = (res[0]["count(*)"] as? String) ?? ""
                    completionHandler(tally, nil)
                    print("\(tally) people")
//                        self.setTally(tally: self.tally)


                    }
                    
                } catch {
                    completionHandler("", error)
                    print(error)
                }
            }
        }.resume()


        
    }
    func setTally(tally :String){
        let tally = tally
        let alert = UIAlertController(title: "There are \(tally) people here", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
//        self.navigationItem.title = "Bye"
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
