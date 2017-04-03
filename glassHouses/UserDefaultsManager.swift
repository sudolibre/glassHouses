//
//  UserDefaultsManager.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/13/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    static let userDefaults = UserDefaults.standard
    
    //KEYS
    static private let userLegislatorsKey = "legislators"
    static private let lastUpdateKey = "lastUpdate"
    static private let APNSTokenKey = "APNSToken"
    
    static var lastUpdate: Date? {
        get {
        let timeInterval = userDefaults.double(forKey: lastUpdateKey)
            if timeInterval == 0 {
                return nil
            } else {
                return Date(timeIntervalSince1970: timeInterval)
            }
        }
        set {
            let timeInterval = newValue!.timeIntervalSince1970
            userDefaults.set(timeInterval, forKey: lastUpdateKey)
        }
        
    }
    
    static func getLegislatorIDs() -> [String]? {
        return userDefaults.stringArray(forKey: userLegislatorsKey)
    }
    
    static func addLegislatorID(_ id: String) {
        if let existingArray = getLegislatorIDs() {
            var updatedArray = existingArray
            updatedArray.append(id)
            userDefaults.set(updatedArray, forKey: userLegislatorsKey)
        } else {
            let newArray = [id]
            userDefaults.set(newArray, forKey: userLegislatorsKey)
        }
        
    }
    
    static func setLegislatorIDs(_ ids: [String]) {
        userDefaults.set(ids, forKey: userLegislatorsKey)
    }
    
    static func setAPNSToken(_ token: String) {
        userDefaults.set("token", forKey: APNSTokenKey)
    }
    
    static func getAPNSToken() -> String? {
        return userDefaults.string(forKey: APNSTokenKey)
    }
}
