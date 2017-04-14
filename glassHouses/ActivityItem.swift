//
//  ActivityItem.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class ActivityItem {
    let legislator: Legislator
    let activityType: ActivityType
    var date: Date {
        switch activityType {
        case .vote(let legislation, _):
            return legislation.date
        case .news(let article):
            return article.date! as Date
        default:
            fatalError("unexpected activity type when calculating date")
        }
    }


    var activityCellViewData: ActivityCellViewData {
        let title = legislator.fullName
        let type = activityType
        let legislatorID = legislator.ID
        var description: String {
            switch activityType {
            case .vote(let legislation, let result):
                return "\(legislator.fullName) voted \(result) \(legislation.id): \(legislation.title)"
            case .sponsor(let legislation):
                return "\(legislator.fullName) sponsored \(legislation.id): \(legislation.title)"
            case .news(let article):
                return "\(article.publisher!) \n\(article.articleDescription!)"
            case .legislationLifecycle:
                return ""
            }
        }
        
        return ActivityCellViewData(title: title, activityDescription: description, activityType: type, date: date, legislatorID: legislatorID)
    }

    init(legislator: Legislator, activityType: ActivityType) {
        self.legislator = legislator
        self.activityType = activityType
    }

}

enum ActivityType {
    case news(Article)
    case vote(Legislation, VoteResult)
    case sponsor(Legislation)
    case legislationLifecycle
}

