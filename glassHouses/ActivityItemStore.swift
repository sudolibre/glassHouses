//
//  ActivityItemStore.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/14/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData

enum APIResponse {
    case success(Data)
    case networkError(HTTPURLResponse)
    case failure(Error)
}

enum VoteResult: CustomStringConvertible {
    case yea
    case nay
    case other
    
    var description: String {
        switch self {
        case .yea:
            return "FOR"
        case .nay:
            return "AGAINST"
        case .other:
            return "OTHER for"
        }
    }
}

class ActivityItemStore {
    let webservice: Webservice!
    
    init(webservice: Webservice) {
        self.webservice = webservice
    }
    
    private static let persistentContainer: NSPersistentContainer = {
        let pc = NSPersistentContainer(name: "glassHouses")
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
    
    static func save() {
        do {
            try context.save()
        } catch {
            fatalError("failed to save context: \(error)")
        }
    }
    
    func fetchActivityItems(legislators: [Legislator], completion: @escaping (ActivityItem) -> ()) {
        //Get Local Items
        let localLegislation = ActivityItemStore.fetchLocalLegislation()
        let localNews = ActivityItemStore.fetchLocalNewsArticles()
        let activityFromLegislation = ActivityItemStore.generateActivity(for: legislators, from: localLegislation)
        let newsActivity = localNews.flatMap({ (article) -> ActivityItem? in
            var activity: ActivityItem? = nil
            let legislator = legislators.first(where: {$0.id == article.legislatorID})
            if let legislator = legislator {
                activity = ActivityItem(legislator: legislator, activityType: .news(article))
            }
            return activity
        })
        
        let activityFromLocal = activityFromLegislation + newsActivity
        
        for activity in activityFromLocal {
            completion(activity)
        }
        //Update local from network
        updateLegislation { (legislation) in
            if let legislation = legislation {
                //TODO: change generate activity to take a single piece of legislation
                let activity = ActivityItemStore.generateActivity(for: legislators, from: [legislation])
                activity.forEach(completion)
                ActivityItemStore.save()
            }
        }
        updateArticles(legislators: legislators) { (articles) in
            if let articles = articles {
                let activity = articles.map({ (article) -> ActivityItem in
                    let legislator = legislators.first(where: {article.legislatorID == $0.id})!
                    return ActivityItem(legislator: legislator, activityType: .news(article))
                })
                activity.forEach(completion)
                ActivityItemStore.save()
            }
        }
    }
    
    static func fetchLocalNewsArticles() -> [Article] {
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
    
    func registerForNews(legislators: [Legislator]) {
        updateArticles(legislators: legislators, completion: {_ = $0})
    }
    
    private func updateArticles(legislators: [Legislator], completion: @escaping ([Article]?) -> ()) {
        let resource = Article.allArticlesResource(for: legislators, into: ActivityItemStore.context)
        webservice.load(resource: resource, completion: completion)
    }
    
    
    private static func fetchLocalLegislation() -> [Legislation] {
        var fetchedLegislation: [Legislation]?
        
        let fetchRequest: NSFetchRequest<Legislation> = Legislation.fetchRequest()
        context.performAndWait {
            fetchedLegislation = try? fetchRequest.execute()
        }
        return fetchedLegislation ?? []
    }
    
    private func updateLegislation(completion: @escaping ((Legislation?) -> ())) {
        
        let resource = Legislation.recentLegislationIDsResource()
        
        webservice.load(resource: resource) { (legislationIDs) in
            if let legislationIDs = legislationIDs {
                let legislationResourceCollection = legislationIDs.map({ (id) -> Resource<Legislation> in
                    return Legislation.legislationResource(withID: id, into: ActivityItemStore.context)
                })
                legislationResourceCollection.forEach({ (resource) in
                    self.webservice.load(resource: resource, completion: completion)
                })
            }
        }
    }
    
    private static func generateActivity(for legislators: [Legislator], from legislationCollection: [Legislation]) -> [ActivityItem] {
        var activity = [ActivityItem]()
        
        for legislation in legislationCollection {
            
            let votes = legislation.votes
            
            for legislator in legislators {
                var vote: VoteResult? = nil
                if !votes.yesVotes.isDisjoint(with: legislator.voterDescriptions) {
                    vote = .yea
                } else if !votes.noVotes.isDisjoint(with: legislator.voterDescriptions) {
                    vote = .nay
                } else if !votes.otherVotes.isDisjoint(with: legislator.voterDescriptions) {
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
