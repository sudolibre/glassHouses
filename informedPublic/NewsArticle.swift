//
//  NewsItem.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/10/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import WebKit

class NewsArticle {
    let publisher: String
    //let date: Date
    let title: String
    let description: String
    let imageURL: URL
    let link: URL
    
    init?(json: [String: Any]) {
        guard let title = json["title"] as? String,
        let description = json["snippet"] as? String,
        let linkString = json["link"] as? String,
        let link = URL(string: linkString),
        let publisher = json["displayLink"] as? String,
        let pagemap = json["pagemap"] as? [String: Any],
        let imageArrayOfDictionaries = pagemap["cse_thumbnail"] as? [[String: Any]],
        let imageDictionary = imageArrayOfDictionaries.first,
        let imageURLString = imageDictionary["src"] as? String,
        let imageURL = URL(string: imageURLString) else {
                return nil
        }
        
        self.title = title
        self.publisher = publisher
        self.description = description
        self.imageURL = imageURL
        self.link = link
    }
    
}
