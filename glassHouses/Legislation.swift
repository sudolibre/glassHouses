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
        
        
        guard let id = json.getStringForKey("bill_id"),
            let documentVersions = json.getArrayOfDictForKey("versions"),
            let recentVersion = documentVersions.last,
            let documentURLString = recentVersion.getStringForKey("url"),
            let documentURL = URL(string: documentURLString),
            let title = json.getStringForKey("title"),
            let description = json.getStringForKey("+description"), //TODO: this is likely specific to GA
            let actionDates = json.getDictForKey("action_dates"),
            let dateString = actionDates.getStringForKey("last"),
            let date = dateFormatter.date(from: dateString),
            let sponsorArray = json.getArrayOfDictForKey("sponsors"),
            let votesArray = json.getArrayOfDictForKey("votes"),
            let yesVotesArray = votesArray.first?.getArrayOfDictForKey("yes_votes"),
            let noVotesArray = votesArray.first?.getArrayOfDictForKey("no_votes"),
            let otherVotesArray = votesArray.first?.getArrayOfDictForKey("other_votes") else {
                return nil
        }
        
//        let yesIDs = yesVotesArray.flatMap({$0["leg_id"] as? String})
//        let noIDs = noVotesArray.flatMap({$0["leg_id"] as? String})
//        let otherIDs = otherVotesArray.flatMap({$0["leg_id"] as? String})
        let voterDescriptionParser = { (dictionary: [String: Any]) -> String? in
            if let legID = dictionary["leg_id"] as? String {
                return legID
            } else {
                return dictionary["name"] as? String
            }
        }
        let yesNames = yesVotesArray.flatMap(voterDescriptionParser)
        let noNames = noVotesArray.flatMap(voterDescriptionParser)
        let otherNames = otherVotesArray.flatMap(voterDescriptionParser)

        //let yesNames = yesVotesArray.flatMap({$0["name"] as? String})
//        let noNames = noVotesArray.flatMap({$0["name"] as? String})
//        let otherNames = otherVotesArray.flatMap({$0["name"] as? String})
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
