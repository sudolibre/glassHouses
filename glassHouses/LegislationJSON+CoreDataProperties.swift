//
//  LegislationJSON+CoreDataProperties.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/15/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData


extension LegislationJSON {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LegislationJSON> {
        return NSFetchRequest<LegislationJSON>(entityName: "LegislationJSON");
    }

    @NSManaged public var id: String?
    @NSManaged public var json: NSDictionary?

}
