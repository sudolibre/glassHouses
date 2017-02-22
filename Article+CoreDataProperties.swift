//
//  Article+CoreDataProperties.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/16/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article");
    }

    @NSManaged public var publisher: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var articleDescription: String?
    @NSManaged public var imageURL: NSURL?
    @NSManaged public var link: NSURL?
    @NSManaged public var legislatorID: String?

}
