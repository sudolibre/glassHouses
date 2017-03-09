//
//  Legislation.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class Legislation {
    var title: String
    var id: String
    var documentURL: URL
    var description: String
    var date: Date
    var votes: Votes
    var sponsorIDs: [String]
    var status: Status
    
    struct Votes {
        let yesVotes: Set<String>
        let noVotes: Set<String>
        let otherVotes: Set<String>
    }
    
    init?(json: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        
        
        guard let id = json["bill_id"] as? String,
            let documentVersions = json["versions"] as? [[String: Any]],
            let recentVersion = documentVersions.last,
            let documentURLString = recentVersion["url"] as? String,
            let documentURL = URL(string: documentURLString),
            let title = json["title"] as? String,
            let description = json["+description"] as? String, //TODO: this is likely specific to GA
            let actionDates = json["action_dates"] as? [String: Any],
            let dateString = actionDates["last"] as? String,
            let date = dateFormatter.date(from: dateString),
            let sponsorArray = json["sponsors"] as? [[String: Any]],
            let votesArray = json["votes"] as? [[String: Any]],
            let yesVotesArray = votesArray.first?["yes_votes"] as? [[String:Any]],
            let noVotesArray = votesArray.first?["no_votes"] as? [[String:Any]],
            let otherVotesArray = votesArray.first?["other_votes"] as? [[String:Any]] else {
                return nil
        }
        
        let yesNames = yesVotesArray.flatMap({$0["name"] as? String})
        let noNames = noVotesArray.flatMap({$0["name"] as? String})
        let otherNames = otherVotesArray.flatMap({$0["name"] as? String})
        self.sponsorIDs = sponsorArray.flatMap({$0["leg_id"] as? String})
        self.date = date
        self.description = description
        self.documentURL = documentURL
        self.title = title
        self.id = id
        self.votes = Votes(yesVotes: Set(yesNames), noVotes: Set(noNames), otherVotes: Set(otherNames))
        
        if actionDates["signed"] as? String != nil {
            status = .law
        } else if actionDates["passed_upper"] as? String != nil {
            status = .senate
        } else if actionDates["passed_lower"] as? String != nil {
            status = .house
        } else {
            status = .introduced
        }
    }
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
}
