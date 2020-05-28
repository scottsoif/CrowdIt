//
//  ViewController.swift
//  CrowdIt
//
//  Created by Scott Soifer on 5/25/20.
//  Copyright © 2020 AGS2. All rights reserved.
//

import UIKit
import GoogleMaps
//import Alamofire
import GooglePlaces
import CoreLocation

struct place: Codable {
    let place_id: String
    let name: String
}
struct resultPlaces: Codable {
    let results: String
}

class ViewController: UIViewController, CLLocationManagerDelegate {

    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    let API_Key = ProcessInfo.processInfo.environment["DEBUGMODE"] ?? ""

    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        placesClient = GMSPlacesClient.shared()
        // Do any additional setup after loading the view.
        GMSServices.provideAPIKey(ProcessInfo.processInfo.environment["DEBUGMODE"] ?? "")
//
        let camera = GMSCameraPosition.camera(withLatitude: 40.807552, longitude: -73.962724, zoom: 10)
        let mapView = GMSMapView.map(withFrame: CGRect.zero,camera: camera)
        view = mapView

        let currentLocation = CLLocationCoordinate2DMake(40.807552, -73.962724)
        let marker = GMSMarker(position: currentLocation)
        marker.title = "Skwl"
        marker.map = mapView
//        if(true){ // if you click on a place
//            print("Ariana") // print out the coordinates
//        }
    }
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
            }
          }
        })
    }
    
    
    @IBAction func postButton(_ sender: UIButton) {

        placesAPITest()
//        googlePlacesVersion()

    
    }
    @IBAction func getButton(_ sender: Any) {
        
        
    }
    
    
    
    func placesAPITest( ) {
        var currentLoc: CLLocation!
        currentLoc = locationManager.location
        let lat = currentLoc.coordinate.latitude
        let lon = currentLoc.coordinate.longitude
        
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lon)&radius=35&key=\(API_Key)") else { return }
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
                            for place in results {
                                print(place["name"] ?? "")
                                print(" here   ***       \(place["place_id"])")
                                let place_id  =  place["place_id"] ?? "" as! String
                                self.sendPost(place_id: place_id)
                            }
//                            print("Success data")
                        } catch {
                            print(error)
                        }
                    }
                }.resume()
        
     }
    
    
    func sendPost(place_id : Any){
        let paramaters = ["id":"12", "zipcode":"11559",  "placeid":place_id]
                guard let url = URL(string: "http://24.44.193.13:60/posts") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                guard let httpBody = try? JSONSerialization.data(withJSONObject: paramaters, options: []) else { return }
                request.httpBody = httpBody
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
                            
                        } catch {
                            print(error)
                        }
                    }
                }.resume()    }


}

