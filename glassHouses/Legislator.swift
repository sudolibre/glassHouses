////
////  Legislator.swift
////  glassHouses
////
////  Created by Jonathon Day on 2/8/17.
////  Copyright © 2017 dayj. All rights reserved.
////
//
//import Foundation
//import UIKit
//import Crashlytics
//
//
//
//class Legislator {
//    var fullName: String
//    var lastName: String
//    var district: Int
//    var party: Party
//    var chamber: Chamber
//    var state: State
//    var title: String {
//        return chamber.description
//    }
//    var photoURL: URL
//    var photoKey: String {
//        return ID
//    }
//    var ID: String
//    
//    var voterDescriptions: Set<String> {
//        var descriptions: Set<String> = []
//        descriptions.insert(ID)
//        //for GA format
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .ordinal
//        let districtDescription = formatter.string(from: district as NSNumber)!
//        descriptions.insert("\(lastName), \(districtDescription)".uppercased())
//        return descriptions
//    }
//    
//    
//
//    
//    init?(json: [String: Any]) {
//        guard let active = json.getBoolForKey("active"),
//            active == true,
//            let ID = json.getStringForKey("leg_id"),
//            let fullName = json.getStringForKey("full_name"),
//            let districtString = json.getStringForKey("district"),
//            let district = Int(districtString),
//            let lastName = json.getStringForKey("last_name"),
//            let partyRawValue = json.getStringForKey("party"),
//            let party = Party(rawValue: partyRawValue.lowercased()),
//            let photoURLString = (json.getStringForKey("photo_url") )?.replacingOccurrences(of: " ", with: "%20", options: [], range: nil),
//            let photoURL = URL(string: photoURLString),
//            let chamberRawValue = json.getStringForKey("chamber"),
//            let stateString = json.getStringForKey("state")?.uppercased(),
//            let state = State(rawValue: stateString),
//            let chamber = Chamber(rawValue: chamberRawValue) else {
//                return nil
//        }
//        
//        self.fullName = fullName
//        self.district = district
//        self.lastName = lastName
//        self.ID = ID
//        self.party = party
//        self.chamber = chamber
//        self.photoURL = photoURL
//        self.state = state
//    }
//}
//
//        
