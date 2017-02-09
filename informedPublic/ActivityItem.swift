//
//  ActivityItem.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class ActivityItem {
    let legislation: Legislation
    let legislator: Legislator?
    //let date: Date
    let activityType: ActivityType
    
    var cellDescription: String {
        switch activityType {
        case .vote(let result):
            return "\(legislator!.fullName) voted \(result) \(legislation.id): \(legislation.title)"
        default:
            return "Nope"
        }
    }
    
    enum ActivityType {
        case news
        case vote(VoteResult)
        case sponsor
        case legislationLifecycle
    }
    
    init(legislation: Legislation, legislator: Legislator, activityType: ActivityType) {
        self.legislation = legislation
        self.legislator = legislator
        //self.date = date
        self.activityType = activityType
    }
    
}
