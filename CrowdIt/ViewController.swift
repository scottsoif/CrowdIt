//
//  ViewController.swift
//  CrowdIt
//
//  Created by Scott Soifer on 5/25/20.
//  Copyright © 2020 AGS2. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GMSServices.provideAPIKey(ProcessInfo.processInfo.environment["DEBUGMODE"] ?? "")
        
        let camera = GMSCameraPosition.camera(withLatitude: 40.807552, longitude: -73.962724, zoom: 10)
        let mapView = GMSMapView.map(withFrame: CGRect.zero,camera: camera)
        view = mapView
        
        let currentLocation = CLLocationCoordinate2DMake(40.807552, -73.962724)
        let marker = GMSMarker(position: currentLocation)
        marker.title = "Skwl"
        marker.map = mapView 
    }


}

