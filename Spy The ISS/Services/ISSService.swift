//
//  ISSService.swift
//  Spy The ISS
//
//  Created by Tom on 22/09/2018.
//  Copyright © 2018 Tom. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ISSServices {
    
    static let shared = ISSServices()
    private init() {}
    
    func getISSInfo(completionHandler: @escaping (ISSInfo?, Error?) -> ()) {
        getDataISS(completionHandler: completionHandler)
    }
    
    func getISSPeople(completionHandler: @escaping ([People]?, Error?) -> ()) {
        getDataISSPeople(completionHandler: completionHandler)
    }
    
    private func getDataISS(completionHandler: @escaping (ISSInfo?, Error?) -> ()) {
        let URL = "http://api.open-notify.org/iss-now.json"
        Alamofire.request(URL).responseJSON { response in
            
            guard response.result.error == nil else {
                print("ERROR:\(String(describing: response.result.error))")
                print(response.result.error!)
                return
            }
            let json = JSON(response.result.value!)
            let ISS = ISSInfo.init(timestamp: json["timestamp"].int!, issPosition: ISSPosition.init(longitude:  Double(json["iss_position"]["longitude"].string!)!, latitude: Double(json["iss_position"]["latitude"].string!)!))
            completionHandler(ISS, nil)
        }
    }
    
    private func getDataISSPeople(completionHandler: @escaping ([People]?, Error?) -> ()) {
        let URL = "http://api.open-notify.org/astros.json"
        Alamofire.request(URL).responseJSON { response in
    
            guard response.result.error == nil else {
                print("ERROR:\(String(describing: response.result.error))")
                print(response.result.error!)
                return
            }
            var people: [People] = []
            let json = JSON(response.result.value!)
            for i in 0...json["number"].int! - 1
            {
                people.append(People.init(craft: json["people"][i]["craft"].string!, name: json["people"][i]["name"].string!))
            }
            completionHandler(people, nil)
        }
    }
}
