//
//  SaveCurrentStatus.swift
//  Spy The ISS
//
//  Created by Tom on 22/09/2018.
//  Copyright © 2018 Tom. All rights reserved.
//

import Foundation

class SaveCurrentStatus {
    
    func saveISSInfo(iss: ISSInfo) {
        
        let StatusDefaults = UserDefaults.standard
        StatusDefaults.set(iss.timestamp, forKey: "timestamp")
        StatusDefaults.set(iss.issPosition.latitude, forKey: "latitude")
        StatusDefaults.set(iss.issPosition.longitude, forKey: "longitude")
    }
    
    func saveISSPeople(people: [People]) {
        
        let StatusDefaults = UserDefaults.standard
        var crafts: [String] = []
        var names: [String] = []
        
        for person in people
        {
            crafts.append(person.craft)
            names.append(person.name)
        }
        StatusDefaults.set(crafts, forKey: "crafts")
        StatusDefaults.set(names, forKey: "names")
    }
}
