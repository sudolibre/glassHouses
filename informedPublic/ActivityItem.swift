//
//  ActivityItem.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class ActivityItem {


    //let date: Date
    let legislator: Legislator
    let activityType: ActivityType

    var activityCellViewData: ActivityCellViewData {
        let title = legislator.fullName
        let image = legislator.photo
        let type = activityType
        var description: String {
            switch activityType {
            case .vote(let legislation, let result):
                return "\(legislator.fullName) voted \(result) \(legislation.id): \(legislation.title)"
            case .sponsor(let legislation):
                return "\(legislator.fullName) sponsored \(legislation.id): \(legislation.title)"
            case .news(let article):
                return "\(article.publisher) \n\(article.description)"
            case .legislationLifecycle:
                return ""
            }
        }
       return ActivityCellViewData(title: title, activityDescription: description, activityType: type, avatarImage: image)
    }

    init(legislator: Legislator, activityType: ActivityType) {
        self.legislator = legislator
        //self.date = date
        self.activityType = activityType
    }

}

enum ActivityType {
    case news(NewsArticle)
    case vote(Legislation, VoteResult)
    case sponsor(Legislation)
    case legislationLifecycle
}

