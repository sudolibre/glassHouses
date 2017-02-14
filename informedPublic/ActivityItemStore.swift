//
//  ActivityItemStore.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/14/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData

class ActivityItemStore {
    
    //owns core data
    let persistentContainer: NSPersistentContainer = {
        let pc = NSPersistentContainer(name: "informedPublic")
        pc.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                print("error creating core data container \(error.localizedDescription)")
            }
        })
        return pc
    }()
    
    //provide fetch functions for activity items
    func fetchActivityItems(completion: @escaping (ActivityItem) -> Void) {
    }

    
}
