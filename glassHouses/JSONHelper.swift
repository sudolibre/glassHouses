//
//  jsonHelper.swift
//  glassHouses
//
//  Created by Jonathon Day on 3/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import Crashlytics

//TODO: replace with modified third party library

extension Dictionary {
    func getDoubleForKey(_ key: String) -> Double? {
        guard let aKey = key as? Key,
            let double = self[aKey] as? Double else {
                let error = NSError(domain: "JSON Mapping: Could not cast value for key \(key) as Double", code: 0, userInfo: nil)
                Crashlytics.sharedInstance().recordError(error)
                return nil
        }
        return double
    }
    
    func getStringForKey(_ key: String) -> String? {
        guard let aKey = key as? Key,
            let string = self[aKey] as? String else {
                let error = NSError(domain: "JSON Mapping: Could not cast value for key \(key) as String", code: 0, userInfo: nil)
                Crashlytics.sharedInstance().recordError(error)
                return nil
        }
        return string
    }
    
    func getArrayOfDictForKey(_ key: String) -> [[String: Any]]? {
        guard let aKey = key as? Key,
            let array = self[aKey] as? Array<Dictionary<String, Any>> else {
                let error = NSError(domain: "JSON Mapping: Could not cast value for key \(key) as Array", code: 0, userInfo: nil)
                Crashlytics.sharedInstance().recordError(error)
                return nil
        }
        return array
    }
    
    func getfDictForKey(_ key: String) -> [String: Any]? {
        guard let aKey = key as? Key,
            let dict = self[aKey] as? Dictionary<String, Any> else {
                let error = NSError(domain: "JSON Mapping: Could not cast value for key \(key) as Dict", code: 0, userInfo: nil)
                Crashlytics.sharedInstance().recordError(error)
                return nil
        }
        return dict
    }
    
    func getBoolForKey(_ key: String) -> Bool? {
        guard let aKey = key as? Key,
            let Bool = self[aKey] as? Bool else {
                let error = NSError(domain: "JSON Mapping: Could not cast value for key \(key) as Bool", code: 0, userInfo: nil)
                Crashlytics.sharedInstance().recordError(error)
                return nil
        }
        return Bool
    }
    
}
