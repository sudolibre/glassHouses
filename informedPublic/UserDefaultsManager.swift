//
//  UserDefaultsManager.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/13/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    static let userDefaults = UserDefaults.standard
    
    static private let userLegislatorsKey = "legislators"
    
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
}
