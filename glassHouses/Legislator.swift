//
//  Legislator.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/8/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit

class Legislator {
    var fullName: String
    var lastName: String
    var district: Int
    var party: Party
    var chamber: Chamber
    var title: String {
        return chamber.description
    }
    var photoURL: URL
    var photoKey: String {
        return ID
    }
    var ID: String
    
    var voterDescription: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        let districtDescription = formatter.string(from: district as NSNumber)!
        return "\(lastName), \(districtDescription)".uppercased()
    }
    
    enum Party: String, CustomStringConvertible {
        case republican
        case democratic
        
        var description: String {
            switch self {
            case .republican:
                return "Republican"
            case .democratic:
                return "Democratic"
            }
        }
    }
    
    enum Chamber: String {
        case upper
        case lower
        
        var description: String {
            switch self {
            case .upper:
                return "Senator"
            case .lower:
                return "Representative"
            }
        }
    }
    
    init?(json: [String: Any]) {
        guard let fullName = json["full_name"] as? String,
        let districtString = json["district"] as? String,
        let district = Int(districtString),
        let ID = json["leg_id"] as? String,
        let lastName = json["last_name"] as? String,
        let partyRawValue = json["party"] as? String,
        let party = Party(rawValue: partyRawValue.lowercased()),
        let photoURLString = (json["photo_url"] as? String)?.replacingOccurrences(of: " ", with: "%20", options: [], range: nil),
        let photoURL = URL(string: photoURLString),
        let chamberRawValue = json["chamber"] as? String,
        let chamber = Chamber(rawValue: chamberRawValue),
        let active = json["active"] as? Bool,
        active == true else {
                return nil
        }
        
        
        self.fullName = fullName
        self.district = district
        self.lastName = lastName
        self.ID = ID
        self.party = party
        self.chamber = chamber
        self.photoURL = photoURL
    }
}

        
