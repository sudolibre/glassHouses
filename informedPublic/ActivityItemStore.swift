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
    static let persistentContainer: NSPersistentContainer = {
        let pc = NSPersistentContainer(name: "informedPublic")
        pc.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                print("error creating core data container \(error.localizedDescription)")
            }
        })
        return pc
    }()
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    

    //provide fetch functions for activity items
    static func fetchActivityItems(legislators: [Legislator], completion: @escaping (ActivityItem) -> Void) {
        //load core data activity items
        let ids = ["GAB00015632", "GAB00015750", "GAB00015925"]
        for id in ids {
            let fetchRequest: NSFetchRequest<LegislationJSON> = LegislationJSON.fetchRequest()
            let predicate = NSPredicate(format: "id == '\(id)'")
            fetchRequest.predicate = predicate
            
            var fetchedPhotos: [LegislationJSON]?
            persistentContainer.viewContext.performAndWait {
                fetchedPhotos = try? fetchRequest.execute()
            }
            if let existingPhoto = fetchedPhotos?.first {
                print("FOUND AND EXISTING ENTRY! \(existingPhoto.id)")
            } else {
                OpenStatesAPI.getJSONForBill(id: id, legislators: legislators, completion: { (id, json) in
                    var legislationJSON: LegislationJSON!
                    self.persistentContainer.viewContext.performAndWait {
                        legislationJSON = LegislationJSON(context: self.persistentContainer.viewContext)
                        legislationJSON.id = id
                        legislationJSON.json = json as NSDictionary
                    }
                    print("storing JSON... \(legislationJSON.id)")
                    try! self.persistentContainer.viewContext.save()
                })
                
                
            }
            
            
            
        }
        
    }
    static func fetchLocalFeed(legislators: [Legislator]) -> [ActivityItem] {
        var fetchedLegislation: [LegislationJSON]?

        let fetchRequest: NSFetchRequest<LegislationJSON> = LegislationJSON.fetchRequest()
        persistentContainer.viewContext.performAndWait {
            fetchedLegislation = try? fetchRequest.execute()
        }
        
        let legislation = fetchedLegislation!.flatMap { (legislationJSON) -> Legislation? in
            let json = legislationJSON.json as! [String: Any]
            return Legislation(json: json)
        }
        
        
        
        if let existingPhoto = fetchedPhotos?.first {
            print("FOUND AND EXISTING ENTRY! \(existingPhoto.id)")
        } else {
            OpenStatesAPI.getJSONForBill(id: id, legislators: legislators, completion: { (id, json) in
                var legislationJSON: LegislationJSON!
                self.persistentContainer.viewContext.performAndWait {
                    legislationJSON = LegislationJSON(context: self.persistentContainer.viewContext)
                    legislationJSON.id = id
                    legislationJSON.json = json as NSDictionary
                }
                print("storing JSON... \(legislationJSON.id)")
                try! self.persistentContainer.viewContext.save()
            })
            
            
        }
        
        
    }
    
    static func generateActivity(for legislators: [Legislator], from _legislationJSON: [LegislationJSON], completion: @escaping (ActivityItem) -> ()) {
        
        for legislationJSON in _legislationJSON {
            
            guard let legislation: Legislation = {
                let json = legislationJSON.json as! [String: Any]
                return Legislation(json: json)!
                }() else {
                    return
            }
            
            var activity: [ActivityItem] = []
            
            for i in votes {
                let yesVotes = i["yes_votes"] as! [[String:Any]]
                let noVotes = i["no_votes"] as! [[String:Any]]
                let otherVotes = i["other_votes"] as! [[String:Any]]
                let yesNames = yesVotes.map({$0["name"] as! String})
                let noNames = noVotes.map({$0["name"] as! String})
                let otherNames = otherVotes.map({$0["name"] as! String})
                var voteCount = 0 {
                    didSet {
                        if voteCount == legislators.count {
                            return
                        }
                    }
                }
                
                for yesName in yesNames {
                    for legislator in legislators {
                        if legislator.voterDescription == yesName {
                            let activityItem = ActivityItem(legislator: legislator, activityType: .vote(legislation, .yea))
                            activity.append(activityItem)
                            voteCount += 1
                        }
                    }
                }
                
                for noName in noNames {
                    for legislator in legislators {
                        if legislator.voterDescription == noName {
                            let activityItem = ActivityItem(legislator: legislator, activityType: .vote(legislation, .nay))
                            activity.append(activityItem)
                            voteCount += 1
                            
                        }
                    }
                }
                
                for otherName in otherNames {
                    for legislator in legislators {
                        if legislator.voterDescription == otherName {
                            let activityItem = ActivityItem(legislator: legislator, activityType: .vote(legislation, .other))
                            activity.append(activityItem)
                            voteCount += 1
                        }
                    }
                }
            }
            
            return activity
        }
            
        }
    }
    static func updateLocalFeed(completion: ([ActivityFeed]) -> ()) {
        let predicate = NSPredicate(format: "id == '\(id)'")
                fetchRequest.predicate = predicate
}
    
    
}
