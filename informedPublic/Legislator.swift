//
//  Legislator.swift
//  informedPublic
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
    var title: String
    var photoURL: URL
    var photo: UIImage?
    var photoKey: String?
    var ID: String
    
    var voterDescription: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        let districtDescription = formatter.string(from: district as NSNumber)!
        return "\(lastName), \(districtDescription)".uppercased()
    }
    
    enum Party: String {
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
    
    init?(jsonArray: [String: Any]) {
        guard let fullName = jsonArray["full_name"] as? String,
        let districtString = jsonArray["district"] as? String,
        let district = Int(districtString),
        let ID = jsonArray["leg_id"] as? String,
        let lastName = jsonArray["last_name"] as? String,
        let partyRawValue = jsonArray["party"] as? String,
        let party = Party(rawValue: partyRawValue.lowercased()),
        let photoURLString = jsonArray["photo_url"] as? String,
        let photoURL = URL(string: photoURLString),
        let chamberRawValue = jsonArray["chamber"] as? String,
        let chamber = Chamber(rawValue: chamberRawValue),
        let active = jsonArray["active"] as? Bool,
        active == true else {
                return nil
        }
        
        
        self.fullName = fullName
        self.district = district
        self.lastName = lastName
        self.ID = ID
        self.party = party
        self.chamber = chamber
        title = chamber.description
        self.photoURL = photoURL
        if let photoData = try? Data.init(contentsOf: photoURL) {
        photo = UIImage(data: photoData)
        }
    }
}

        
