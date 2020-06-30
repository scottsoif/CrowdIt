//
//  NetworkUtility.swift
//  CrowdIt
//
//  Created by Ariana Gewurz and Scott Soifer on 6/2/20.
//  Copyright © 2020 AGS2. All rights reserved.
//

import UIKit
import GoogleMaps
//import Alamofire
import GooglePlaces
import CoreLocation


class NetworkUtility: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {  // TODO (GMSMapViewDelegate needed?

    static let shared = NetworkUtility()
    
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    let API_Key = ProcessInfo.processInfo.environment["DEBUGMODE"] ?? ""

    
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
    
    
    
    @objc func placesAPI( ) {
        var currentLoc: CLLocation!
        var lat = 0.0
        var lon = 0.0
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways && locationManager.location != nil) {
                   currentLoc = locationManager.location
                    lat = currentLoc.coordinate.latitude
                    lon = currentLoc.coordinate.longitude
                  
               }
//        var currentLoc: CLLocation!
//        currentLoc = locationManager.location
//        let lat = currentLoc.coordinate.latitude
//        let lon = currentLoc.coordinate.longitude
        
        
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
                            print("placesAPI statusCode: \(httpResponse.statusCode)")
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
        let paramaters = ["userid":"\(UIDevice.current.identifierForVendor?.uuidString ?? "0")", "zipcode":"00000",  "placeid":place_id]
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
                            print("sendPost statusCode: \(httpResponse.statusCode)")
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
                    print("sendGetReq statusCode: \(httpResponse.statusCode)")
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
    
}
