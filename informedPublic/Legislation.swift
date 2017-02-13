//
//  Legislation.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class Legislation {
    var title: String
    var id: String
    var documentURL: URL
    var date: Date
    
    init?(json: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        
        guard let documentVersions = json["versions"] as? [[String: Any]],
        let recentVersion = documentVersions.last,
        let documentURLString = recentVersion["url"] as? String,
        let documentURL = URL(string: documentURLString),
        let title = json["title"] as? String,
        let id = json["bill_id"] as? String,
        let actionDates = json["action_dates"] as? [String: Any],
        let dateString = actionDates["last"] as? String,
        let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        self.date = date
        self.documentURL = documentURL
        self.title = title
        self.id = id
        
    }
}
