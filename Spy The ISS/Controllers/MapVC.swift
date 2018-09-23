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
    
    var iss = ISSInfo(timestamp: 0, issPosition: ISSPosition(longitude: 0, latitude: 0))
    let lastUpdateL = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 21))
    var peopleOnSpace: [People] = []
    var mapView = MGLMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        timer()
    }
    
    func prepareView() {
        if UserDefaults.standard.value(forKey: "timestamp") != nil && UserDefaults.standard.value(forKey: "latitude") != nil && UserDefaults.standard.value(forKey: "longitude") != nil
        {
            iss.timestamp = UserDefaults.standard.value(forKey: "timestamp") as! Int
            iss.issPosition.latitude = UserDefaults.standard.value(forKey: "latitude") as! Double
            iss.issPosition.longitude = UserDefaults.standard.value(forKey: "longitude") as! Double
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
        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
            (_) in
            let save = SaveCurrentStatus()
            let services = ISSServices.shared
            services.getISSPeople(completionHandler: {responseObject, error in
                if error == nil
                {
                    self.peopleOnSpace = responseObject!
                    save.saveISSPeople(people: responseObject!)
                }else {
                    self.lastUpdateL.text = "Error: \(String(describing: error)))"
                }
            })
            
            services.getISSInfo() { responseObject, error in
                if error == nil
                {
                    self.iss = responseObject!
                    self.mapView.setCenter(CLLocationCoordinate2D(latitude: Double(self.iss.issPosition.latitude), longitude: Double(self.iss.issPosition.longitude)), zoomLevel: 3, animated: true)
                    self.addMarker(latitude: Double(self.iss.issPosition.latitude), longitude: Double(self.iss.issPosition.longitude))
                    save.saveISSInfo(iss: self.iss)
                    self.updateLabel()
                    return
                }else {
                    self.lastUpdateL.text = "Error: \(String(describing: error)))"
                }
            }
        }
    }
    // func converting list of People to String
    func listToString(list: [People]) -> String {
        var stringPeopleOnSpace = ""
        for person in list
        {
            stringPeopleOnSpace.append(person.name + ", ")
        }
        if !stringPeopleOnSpace.isEmpty {
            stringPeopleOnSpace = String(stringPeopleOnSpace.dropLast())
        }
        return stringPeopleOnSpace
    }
    //LABEL with time of last update
    func DrawLabel() {
        lastUpdateL.center = CGPoint(x: view.frame.size.width / 2, y: 100)
        lastUpdateL.textAlignment = .center
        if iss.timestamp == 0
        {
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
        
        annotation.subtitle = listToString(list: peopleOnSpace)
        
        if mapView.annotations?.count ?? 0 > 0 {
            
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations!)
        }
        mapView.addAnnotation(annotation)
    }
    // Showing information added to marker
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}
