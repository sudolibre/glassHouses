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
        guard let aKey = key as? Key else {
            return nil
        }
        guard let double = self[aKey] as? Double else {
            reportFailure(key: key, type: "Double", raw: self[aKey])
            return nil
        }
        return double
    }
    
    func getStringForKey(_ key: String) -> String? {
        guard let aKey = key as? Key else {
            return nil
        }
        guard let String = self[aKey] as? String else {
            reportFailure(key: key, type: "String", raw: self[aKey])
            return nil
        }
        return String
    }
    
    func getArrayOfDictForKey(_ key: String) -> [[String: Any]]? {
        guard let aKey = key as? Key else {
            return nil
        }
        guard let array = self[aKey] as? Array<Dictionary<String, Any>> else {
            reportFailure(key: key, type: "ArrayOfDict", raw: self[aKey])
            return nil
        }
        return array
    }
    
    func getDictForKey(_ key: String) -> [String: Any]? {
        guard let aKey = key as? Key else {
            return nil
        }
        guard let dict = self[aKey] as? Dictionary<String, Any> else {
            reportFailure(key: key, type: "Dictionary", raw: self[aKey])
            return nil
        }
        return dict
    }
    
    func getBoolForKey(_ key: String) -> Bool? {
        guard let aKey = key as? Key else {
            return nil
        }
        guard let Bool = self[aKey] as? Bool else {
            reportFailure(key: key, type: "Bool", raw: self[aKey])
            return nil
        }
        return Bool
    }
    
    func reportFailure(key: String, type: String, raw: Any?) {
        Answers.logCustomEvent(withName: "JSON Mapping Failure",
                               customAttributes: [
                                "Key": key,
                                "Target Type": type,
                                "Data Preview": raw.debugDescription
            ])
    }
    
}
