//
//  NewsItem.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/10/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import WebKit

class NewsArticle {
    let publisher: String
    let date: Date
    let title: String
    let description: String
    var imageURL: URL? = nil
    let link: URL
    
    init?(json: [String: Any]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let title = json["name"] as? String,
            let description = json["description"] as? String,
            let linkString = json["url"] as? String,
            let link = URL(string: linkString),
            let providerDictionary = json["provider"] as? [[String: Any]],
            let firtProvider = providerDictionary.first,
            let publisher = firtProvider["name"] as? String,
            let dateString = json["datePublished"] as? String else {
                return nil
        }
        
        if let imageDictionary = json["image"] as? [String: Any],
            let thumbnailDictionary = imageDictionary["thumbnail"] as? [String: Any],
            let imageURLString = thumbnailDictionary["contentURL"] as? String,
            let _imageURL = URL(string: imageURLString) {
            self.imageURL = _imageURL
        }

        if let date = dateFormatter.date(from: dateString) {
            self.date = date
        } else {
             dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                self.date = date
            } else {
                return nil
            }
        }

        self.title = title
        self.publisher = publisher
        self.description = description
        self.link = link
    }
    
}
