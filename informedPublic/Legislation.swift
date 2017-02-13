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
    
    init?(json: [String: Any]) {
        guard let documentVersions = json["versions"] as? [[String: Any]],
        let recentVersion = documentVersions.last,
        let documentURLString = recentVersion["url"] as? String,
        let documentURL = URL(string: documentURLString),
        let title = json["title"] as? String,
        let id = json["bill_id"] as? String else {
            return nil
        }
        self.documentURL = documentURL
        self.title = title
        self.id = id
        
    }
}
