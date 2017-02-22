//
//  ActivityItemStore.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/14/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData

class ActivityItemStore {
    
    //owns core data
    private static let persistentContainer: NSPersistentContainer = {
        let pc = NSPersistentContainer(name: "glassHouses")
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
    
    static func save() {
        do {
            try context.save()
        } catch {
            fatalError("failed to save context: \(error)")
        }
    }
    
    static func fetchActivityItems(legislators: [Legislator], completion: @escaping (ActivityItem) -> ()) {
        let localLegislation = fetchLocalLegislation()
        let localNews = fetchLocalNewsArticles()
        let activityFromLegislation = generateActivity(for: legislators, from: localLegislation)
        let newsActivity = localNews.flatMap({ (article) -> ActivityItem? in
            var activity: ActivityItem? = nil
            let legislator = legislators.first(where: {$0.ID == article.legislatorID})
            if let legislator = legislator {
                activity = ActivityItem(legislator: legislator, activityType: .news(article))
            }
            return activity
        })
        
        let activityFromLocal = activityFromLegislation + newsActivity
        
        for activity in activityFromLocal {
            completion(activity)
        }
        updateLocalLegislation { (legislationJSON) in
            let activityFromNetwork = generateActivity(for: legislators, from: [legislationJSON])
            if let activity = activityFromNetwork.first {
                completion(activity)
            }
        }
        updateLocalArticles(legislators: legislators, completion: completion)
    }
    
    private static func fetchLocalNewsArticles() -> [Article] {
        var fetchedArticles: [Article]?
        
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        context.performAndWait {
            fetchedArticles = try? fetchRequest.execute()
        }
        
        if let fetchedArticles = fetchedArticles {
            print("fetched \(fetchedArticles.count) articles")
            return fetchedArticles
        } else {
            return []
        }
    }
    
    private static func updateLocalArticles(legislators: [Legislator], completion: ((ActivityItem) -> ())?) {
        NewsSearchAPI.fetchNewsForLegislators(legislators) { (legislator, dictionaries) in
            for json in dictionaries {
                
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
                        continue
                }
                
                var date: NSDate?
                
                if let _date = dateFormatter.date(from: dateString) {
                    date = _date as NSDate
                } else {
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let _date = dateFormatter.date(from: dateString) {
                        date = _date as NSDate
                    } else {
                        continue
                    }
                }
                
                let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
                let predicate = NSPredicate(format: "title == '\(title)'")
                fetchRequest.predicate = predicate
                var existingArticle: [Article]!
                context.performAndWait {
                    do {
                        existingArticle = try fetchRequest.execute()
                    } catch {
                        print("failed to query core data: \(error)")
                        existingArticle = []
                    }
                }
                
                
                if existingArticle.count > 0 {
                    print("article already in core data")
                } else {
                    var article: Article!
                    self.context.performAndWait {
                        article = Article(context: context)
                        article.title = title
                        article.publisher = publisher
                        article.articleDescription = description
                        article.link = link as NSURL
                        article.date = date!
                        article.legislatorID = legislator.ID
                        if let imageDictionary = json["image"] as? [String: Any],
                            let thumbnailDictionary = imageDictionary["thumbnail"] as? [String: Any],
                            let imageURLString = thumbnailDictionary["contentURL"] as? String,
                            let _imageURL = URL(string: imageURLString) {
                            article.imageURL = _imageURL as NSURL
                        }
                    }
                    
                    if let completion = completion {
                        let activity = ActivityItem(legislator: legislator, activityType: .news(article))
                        completion(activity)
                    }
                }
            }
        }
    }
    
    
    private static func fetchLocalLegislation() -> [LegislationJSON] {
        var fetchedLegislation: [LegislationJSON]?
        
        let fetchRequest: NSFetchRequest<LegislationJSON> = LegislationJSON.fetchRequest()
        context.performAndWait {
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
            context.performAndWait {
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
                self.context.performAndWait {
                    legislationJSON = LegislationJSON(context: context)
                    legislationJSON.id = id
                    legislationJSON.json = json as NSDictionary
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
