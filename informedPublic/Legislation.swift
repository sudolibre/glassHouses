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
    
    init(json: [String: Any]) {
        self.title = json["title"] as! String
        self.id = json["bill_id"] as! String
    }
}
