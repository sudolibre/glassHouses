//
//  Legislation+CoreDataClass.swift
//  GlassHouses
//
//  Created by Jonathon Day on 4/14/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData

struct Votes {
    let yesVotes: Set<String>
    let noVotes: Set<String>
    let otherVotes: Set<String>
}
enum Status: Int {
    case introduced = 1
    case house = 2
    case senate = 3
    case law = 4

    static var count: Int {
        return 4
    }

    static var descriptions: [String] {
        return ["Introduced", "House", "Senate", "Law"]
    }
    
    init(actions: [String: Any]?) {
        guard let actions = actions else {
            self = .introduced
            return
        }
        if actions["signed"] as? String != nil {
            self = .law
        } else if actions["passed_upper"] as? String != nil {
            self = .senate
        } else if actions["passed_lower"] as? String != nil {
            self = .house
        } else {
            self = .introduced
        }
    }
}

@objc(Legislation)
public class Legislation: NSManagedObject {
    var documentURL: URL {
        return self.documentURLCD as URL
    }

    var date: Date {
        return self.dateCD as Date
    }
    var votes: Votes {
        let yes = yesVotes as! Set<String>
        let no = noVotes as! Set<String>
        let other = otherVotes as! Set<String>
        return Votes(yesVotes: yes, noVotes: no, otherVotes: other)
    }
    var sponsorIDs: Array<[String: String]> {
        return sponsorIDsCD as! Array<[String: String]>
    }
    
    var status: Status {
        return Status(rawValue: Int(statusCD))!
    }
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        return dateFormatter
    }()
}
