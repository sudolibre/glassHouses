//
//  Legislator+CoreDataProperties.swift
//  GlassHouses
//
//  Created by Jonathon Day on 4/17/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData


extension Legislator {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Legislator> {
        return NSFetchRequest<Legislator>(entityName: "Legislator")
    }

    @NSManaged public var fullName: String
    @NSManaged public var lastName: String
    @NSManaged public var district: Int32
    @NSManaged public var partyCD: String
    @NSManaged public var chamberCD: String
    @NSManaged public var stateCD: String
    @NSManaged public var photoURLCD: NSURL?
    @NSManaged public var id: String
    @NSManaged public var following: Bool

}
