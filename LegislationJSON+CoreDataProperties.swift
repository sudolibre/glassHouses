//
//  LegislationJSON+CoreDataProperties.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/14/17.
//  Copyright © 2017 dayj. All rights reserved.
//  This file was automatically generated and should not be edited.
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
