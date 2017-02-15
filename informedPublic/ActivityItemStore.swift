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
    private static let persistentContainer: NSPersistentContainer = {
        let pc = NSPersistentContainer(name: "informedPublic")
        pc.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                print("error creating core data container \(error.localizedDescription)")
            }
        })
        return pc
    }()
    
    private static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    
    
    //provide fetch functions for activity items
    static func fetchActivityItems(legislators: [Legislator], completion: @escaping (ActivityItem) -> Void) {
        let localLegislation = fetchLocalLegislation()
        let activityFromLocal = generateActivity(for: legislators, from: localLegislation)
        for activity in activityFromLocal {
            completion(activity)
        }
        updateLocalLegislation { (legislationJSON) in
            let activityFromNetwork = generateActivity(for: legislators, from: [legislationJSON])
            if let activity = activityFromNetwork.first {
                completion(activity)
            }
        }
    }
    
    private static func fetchLocalLegislation() -> [LegislationJSON] {
        var fetchedLegislation: [LegislationJSON]?
        
        let fetchRequest: NSFetchRequest<LegislationJSON> = LegislationJSON.fetchRequest()
        persistentContainer.viewContext.performAndWait {
            fetchedLegislation = try? fetchRequest.execute()
        }
        
        if let fetchedLegislation = fetchedLegislation {
            print("fetched \(fetchedLegislation.count) legislation")
            return fetchedLegislation
        } else {
            return []
        }
    }
    
    private static func updateLocalLegislation(completion: ((LegislationJSON) -> ())?) {
        let fetchRequest: NSFetchRequest<LegislationJSON> = LegislationJSON.fetchRequest()
        var date: Date = {
            let calendar = Calendar.current
            let current = Date()
            let weekPrior = calendar.date(byAdding: .day, value: -7, to: current)
            return weekPrior!
        }()

        if let count = try? context.count(for: fetchRequest),
            let lastUpdate = UserDefaultsManager.lastUpdate,
            count > 0 {
            date = lastUpdate
        }
        
        OpenStatesAPI.getNewBills(since: date, forEach: { (id, json) in
            let predicate = NSPredicate(format: "id == '\(id)'")
            fetchRequest.predicate = predicate
            var existingLegislation: [LegislationJSON]!
            persistentContainer.viewContext.performAndWait {
                do {
                    existingLegislation = try fetchRequest.execute()
                } catch {
                    print("failed to query core data: \(error)")
                    existingLegislation = []
                }
            }
            
            if existingLegislation.count > 0 {
                print("legislation already in core data")
            } else {
                var legislationJSON: LegislationJSON!
                self.persistentContainer.viewContext.performAndWait {
                    legislationJSON = LegislationJSON(context: self.persistentContainer.viewContext)
                    legislationJSON.id = id
                    legislationJSON.json = json as NSDictionary
                }
                do {
                    try self.persistentContainer.viewContext.save()
                    print("added new legislation to core data from API")
                } catch {
                    fatalError("failed to save context: \(error)")
                }
                if let completion = completion {
                    completion(legislationJSON)
                }
            }
        }, whenDone: { 
            UserDefaultsManager.lastUpdate = Date()
        })
    }
    
    private static func generateActivity(for legislators: [Legislator], from _legislationJSON: [LegislationJSON]) -> [ActivityItem] {
        var activity = [ActivityItem]()
        
        for legislationJSON in _legislationJSON {
            guard let json = legislationJSON.json as? [String: Any],
                let legislation = Legislation(json: json) else {
                    return activity
            }
            
            let votes = legislation.votes
            
            for legislator in legislators {
                var vote: VoteResult? = nil
                if votes.yesVotes.contains(legislator.voterDescription) {
                    vote = .yea
                } else if votes.noVotes.contains(legislator.voterDescription) {
                    vote = .nay
                } else if votes.otherVotes.contains(legislator.voterDescription) {
                    vote = .other
                }
                
                if let vote = vote {
                    let activityItem = ActivityItem(legislator: legislator, activityType: .vote(legislation, vote))
                    activity.append(activityItem)
                }
            }
        }
        return activity
    }
}
