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
    
    static func setAPNSToken(_ token: String) {
        userDefaults.set(token, forKey: APNSTokenKey)
    }
    
    static func getAPNSToken() -> String? {
        return userDefaults.string(forKey: APNSTokenKey)
    }
}
