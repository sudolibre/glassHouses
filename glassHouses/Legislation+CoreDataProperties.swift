//
//  Legislation+CoreDataProperties.swift
//  GlassHouses
//
//  Created by Jonathon Day on 4/14/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData


extension Legislation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Legislation> {
        return NSFetchRequest<Legislation>(entityName: "Legislation")
    }

    @NSManaged public var title: String
    @NSManaged public var documentURLCD: NSURL
    @NSManaged public var billDescription: String
    @NSManaged public var dateCD: NSDate
    @NSManaged public var yesVotes: NSSet
    @NSManaged public var noVotes: NSSet
    @NSManaged public var otherVotes: NSSet
    @NSManaged public var sponsorIDsCD: NSSet
    @NSManaged public var statusCD: Int32
    @NSManaged public var id: String

}
