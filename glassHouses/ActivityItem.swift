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
            return article.date as Date
        default:
            fatalError("unexpected activity type when calculating date")
        }
    }


    var activityCellViewData: ActivityCellViewData {
        let title = legislator.fullName
        let type = activityType
        let legislatorID = legislator.id
        var description: String {
            switch activityType {
            case .vote(let legislation, let result):
                return "\(legislator.fullName) voted \(result) \(legislation.id): \(legislation.title)"
            case .sponsor(let legislation):
                return "\(legislator.fullName) sponsored \(legislation.id): \(legislation.title)"
            case .news(let article):
                return "\(article.publisher) \n\(article.articleDescription)"
            }
        }
        
        return ActivityCellViewData(title: title, activityDescription: description, activityType: type, date: date, legislatorID: legislatorID)
    }

    init(legislator: Legislator, activityType: ActivityType) {
        self.legislator = legislator
        self.activityType = activityType
    }

}

extension ActivityItem: Hashable {
    var hashValue: Int {
        var activityHash: Int {
            switch activityType {
            case .news( let article):
                return article.link.hashValue
            case .sponsor(let legislation):
                return legislation.id.hashValue
            case .vote(let legislation, let voteResult):
                return legislation.hashValue ^ voteResult.hashValue
            }
        }
        return date.hashValue ^ activityHash ^ legislator.hashValue
    }

    static func ==(lhs: ActivityItem, rhs: ActivityItem) -> Bool {
        return lhs.date == rhs.date && lhs.activityType == rhs.activityType && lhs.legislator == rhs.legislator
    }
    
}

enum ActivityType: Equatable {
    case news(Article)
    case vote(Legislation, VoteResult)
    case sponsor(Legislation)
    
    static func ==(lhs: ActivityType, rhs: ActivityType) -> Bool {
        switch (lhs, rhs) {
        case (.news(let article1), .news(let article2)):
            return article1 == article2
        case (.vote(let legislation1, let result1), .vote(let legislation2, let result2)):
            return legislation1 == legislation2 && result1 == result2
        case (.sponsor(let legislation1), .sponsor(let legislation2)):
            return legislation1 == legislation2
        default:
            return false
        }
    }
}

