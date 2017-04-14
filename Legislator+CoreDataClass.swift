//
//  Legislator+CoreDataClass.swift
//  GlassHouses
//
//  Created by Jonathon Day on 4/14/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData

enum Party: String, CustomStringConvertible {
    case republican
    case democratic
    case independent
    
    var description: String {
        switch self {
        case .republican:
            return "Republican"
        case .democratic:
            return "Democratic"
        case .independent:
            return "Independent"
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

@objc(Legislator)
public class Legislator: NSManagedObject {
    
    var title: String {
        return chamber.description
    }
    var photoKey: String {
        return self.id
    }    
    var voterDescriptions: Set<String> {
        var descriptions: Set<String> = []
        descriptions.insert(self.id)
        //for GA format
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        let districtDescription = formatter.string(from: district as NSNumber)!
        descriptions.insert("\(lastName), \(districtDescription)".uppercased())
        return descriptions
    }
    
    var state: State {
        return State(rawValue: stateCD)!
    }


    var party: Party {
        return Party(rawValue: partyCD.lowercased())!
    }
    
    var chamber: Chamber {
        return Chamber(rawValue: chamberCD)!
    }
    
    var photoURL: URL {
        return photoURLCD as! URL
    }
}
