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
        let userDef = UserDefaults.standard
        userDef.set(iss.timestamp, forKey: "timestamp")
        userDef.set(iss.issPosition.latitude, forKey: "latitude")
        userDef.set(iss.issPosition.longitude, forKey: "longitude")
    }
}
