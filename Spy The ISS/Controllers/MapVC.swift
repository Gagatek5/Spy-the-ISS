//
//  MapVC.swift
//  Spy The ISS
//
//  Created by Tom on 22/09/2018.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import Mapbox

class MapVC: UIViewController  {
    
    private var iss = ISSInfo(timestamp: 0, issPosition: ISSPosition(longitude: 0, latitude: 0))
    private let lastUpdateL = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 21))
    private var peopleOnSpace:[People] = []
    private var mapView = MGLMapView()
    
    private let timeInterval:Double = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        timer()
    }
    
    func prepareView() {
        let userDef = UserDefaults.standard
        if userDef.value(forKey: "timestamp") != nil && userDef.value(forKey: "latitude") != nil && userDef.value(forKey: "longitude") != nil {
            iss.timestamp = userDef.value(forKey: "timestamp") as! Int
            iss.issPosition.latitude = userDef.value(forKey: "latitude") as! Double
            iss.issPosition.longitude = userDef.value(forKey: "longitude") as! Double
        }
        
        mapView = MGLMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: Double(self.iss.issPosition.latitude), longitude: Double(self.iss.issPosition.longitude)), zoomLevel: 3, animated: false)
        self.view.addSubview(mapView)
        mapView.styleURL = MGLStyle.satelliteStyleURL
        mapView.delegate = self
        self.addMarker(latitude: Double(self.iss.issPosition.latitude), longitude: Double(self.iss.issPosition.longitude))
        DrawLabel()
    }
    // timer updating information about ISS
    func timer() {
        _ = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) {
            (_) in
            let save = SaveCurrentStatus()
            let services = ISSServices.shared
            
            services.getISSPeople(completionHandler: {responseObject, error in
                if error == nil {
                    self.peopleOnSpace = responseObject!
                    save.saveISSPeople(people: responseObject!)
                } else {
                    self.lastUpdateL.text = "Error: \(String(describing: error)))"
                }
            })
            
            services.getISSInfo() { responseObject, error in
                if error == nil {
                    self.iss = responseObject!
                    self.mapView.setCenter(CLLocationCoordinate2D(latitude: Double(self.iss.issPosition.latitude), longitude: Double(self.iss.issPosition.longitude)), zoomLevel: 3, animated: true)
                    self.addMarker(latitude: Double(self.iss.issPosition.latitude), longitude: Double(self.iss.issPosition.longitude))
                    save.saveISSInfo(iss: self.iss)
                    self.updateLabel()
                    return
                } else {
                    self.lastUpdateL.text = "Error: \(String(describing: error)))"
                }
            }
        }
    }
    //LABEL with time of last update
    func DrawLabel() {
        lastUpdateL.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 10)
        lastUpdateL.textAlignment = .center
        
        if iss.timestamp == 0 {
            lastUpdateL.text = "First run of Spy the ISS wait for update"
        } else {
            lastUpdateL.text = "Last update: \(Date(timeIntervalSince1970: TimeInterval(iss.timestamp)))"
        }
        
        lastUpdateL.backgroundColor = UIColor.white
        self.view.addSubview(lastUpdateL)
    }
    // func to update text in label
    func updateLabel() {
        lastUpdateL.text = "Last update: \(Date(timeIntervalSince1970: TimeInterval(iss.timestamp)))"
    }
}

extension MapVC: MGLMapViewDelegate {
    // Adding marker
    func addMarker(latitude: Double, longitude: Double) {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = "ISS current Location"
        
        let names: [String] = peopleOnSpace.map({$0.name})
        annotation.subtitle =  names.joined(separator: ", ")
        
        removeMarker()
        mapView.addAnnotation(annotation)
    }
    // Marker Remover
    func removeMarker() {
        if mapView.annotations?.count ?? 0 > 0 {
            
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations!)
        }
    }
    // Showing information added to marker
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}
