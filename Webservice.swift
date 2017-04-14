//
//  WebService.swift
//  GlassHouses
//
//  Created by Jonathon Day on 4/13/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

extension Resource {
    init(url: URL, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

final class Webservice {
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            let urlResponse = response as! HTTPURLResponse
            let code = urlResponse.statusCode
            completion(resource.parse(data))
            }.resume()
    }
}


extension Legislator {
    typealias Coordinates = (lat: Double,long: Double)
    
    static func fromJSON(_ json: [String: Any], into context: NSManagedObjectContext) -> Legislator? {
            guard let active = json.getBoolForKey("active"),
                active == true,
                let id = json.getStringForKey("leg_id"),
                let fullName = json.getStringForKey("full_name"),
                let districtString = json.getStringForKey("district"),
                let district = Int(districtString),
                let lastName = json.getStringForKey("last_name"),
                let partyRawValue = json.getStringForKey("party"),
                let photoURLString = (json.getStringForKey("photo_url") )?.replacingOccurrences(of: " ", with: "%20", options: [], range: nil),
                let photoURL = NSURL(string: photoURLString),
                let chamberRawValue = json.getStringForKey("chamber"),
                let stateString = json.getStringForKey("state")?.uppercased() else {
                    return nil
            }
        
        let fetchRequest: NSFetchRequest<Legislator> = Legislator.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Legislator.id)) == '\(id)'")
        fetchRequest.predicate = predicate
        
        var fetchedLegislator: [Legislator]?
        context.performAndWait {
            fetchedLegislator = try? fetchRequest.execute()
        }
        if let existingLegislator = fetchedLegislator?.first {
            return existingLegislator
        }
        
        var legislator: Legislator!
        context.performAndWait {
            legislator = Legislator(context: context)
            legislator.fullName = fullName
            legislator.district = Int32(district)
            legislator.lastName = lastName
            legislator.id = id
            legislator.partyCD = partyRawValue
            legislator.chamberCD = chamberRawValue
            legislator.photoURLCD = photoURL
            legislator.stateCD = stateString
        }
        return legislator
    }
    
    static func allLegislatorsResource(at coordinates: Coordinates, into context: NSManagedObjectContext) -> Resource<[Legislator]> {
        let baseUrl = "https://openstates.org/api/v1/"
        let url = URL(string: baseUrl.appending("legislators/geo/?lat=\(coordinates.lat)&long=\(coordinates.long)"))!
        let resource = Resource<[Legislator]>(url: url) { (json) -> [Legislator]? in
            guard let dictionaries = json as? [[String: Any]] else { return nil }
            return dictionaries.flatMap({Legislator.fromJSON($0, into: context)})
        }
        return resource
    }
    
    static func legislatorResource(withID id: String, into context: NSManagedObjectContext) -> Resource<Legislator> {
        let baseUrl = URL(string: "https://openstates.org/api/v1/")!
        let url = baseUrl.appendingPathComponent("legislators/\(id)")
        let resource = Resource<Legislator>(url: url) { (json) -> Legislator? in
            guard let dictionary = json as? [String: Any] else { return nil }
            return Legislator.fromJSON(dictionary, into: context)
        }
        return resource
    }
}




extension Legislation {
    static func fromJSON(_ json: [String: Any], into context: NSManagedObjectContext) -> Legislation? {
        guard let id = json.getStringForKey("bill_id"),
            let documentVersions = json.getArrayOfDictForKey("versions"),
            let recentVersion = documentVersions.last,
            let documentURLString = recentVersion.getStringForKey("url"),
            let documentURL = URL(string: documentURLString),
            let title = json.getStringForKey("title"),
            let description = json.getStringForKey("+description"), //TODO: this is likely specific to GA
            let actionDates = json.getDictForKey("action_dates"),
            let dateString = actionDates.getStringForKey("last"),
            let date = Legislation.dateFormatter.date(from: dateString),
            let sponsorArray = json.getArrayOfDictForKey("sponsors"),
            let votesArray = json.getArrayOfDictForKey("votes"),
            let yesVotesArray = votesArray.first?.getArrayOfDictForKey("yes_votes"),
            let noVotesArray = votesArray.first?.getArrayOfDictForKey("no_votes"),
            let otherVotesArray = votesArray.first?.getArrayOfDictForKey("other_votes") else {
                return nil
        }
        
        let fetchRequest: NSFetchRequest<Legislation> = Legislation.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Legislation.id)) == '\(id)'")
        fetchRequest.predicate = predicate
        
        var fetchedLegislation: [Legislation]?
        context.performAndWait {
            fetchedLegislation = try? fetchRequest.execute()
        }
        if let existingLegislation = fetchedLegislation?.first {
            return existingLegislation
        }
        
        let voterDescriptionParser = { (dictionary: [String: Any]) -> String? in
            if let legID = dictionary["leg_id"] as? String {
                return legID
            } else {
                return dictionary["name"] as? String
            }
        }
        let yesNames = yesVotesArray.flatMap(voterDescriptionParser)
        let noNames = noVotesArray.flatMap(voterDescriptionParser)
        let otherNames = otherVotesArray.flatMap(voterDescriptionParser)
        var status: Status!
        if actionDates["signed"] as? String != nil {
            status = .law
        } else if actionDates["passed_upper"] as? String != nil {
            status = .senate
        } else if actionDates["passed_lower"] as? String != nil {
            status = .house
        } else {
            status = .introduced
        }
        let sponsorIDArray = sponsorArray.flatMap({$0["leg_id"] as? String})
        let sponsorIDSet = NSSet(array: sponsorIDArray)
        
        var legislation: Legislation!
        context.performAndWait {
            legislation = Legislation(context: context)
            legislation.sponsorIDsCD = sponsorIDSet
            legislation.dateCD = date as NSDate
            legislation.billDescription = description
            legislation.documentURLCD = documentURL as NSURL
            legislation.title = title
            legislation.id = id
            legislation.yesVotes = NSSet(array: yesNames)
            legislation.noVotes = NSSet(array: noNames)
            legislation.otherVotes = NSSet(array: otherNames)
            legislation.statusCD = Int32(status.rawValue)

        }
        return legislation
    }
    
    static func legislationResource(withID id: String, into context: NSManagedObjectContext) -> Resource<Legislation> {
        let baseUrl = "https://openstates.org/api/v1/"
        let url = URL(string: baseUrl.appending("bills/\(id)"))!
        let resource = Resource<Legislation>(url: url) { (json) -> Legislation? in
            guard let dictionary = json as? [String: Any] else { return nil }
            return Legislation.fromJSON(dictionary, into: context)
        }
        return resource

    }
    static func recentLegislationIDsResource() -> Resource<[String]> {
        let getIDsForVotedBills = { (array: [[String: Any]]) -> [String] in
            let filteredArray = array.filter({ (dictionary) -> Bool in
                let votesArray = dictionary["votes"] as! [[String: Any]]
                return !votesArray.isEmpty
            })
            return filteredArray.map({ $0["id"] as! String})
        }
        let baseUrl = "https://openstates.org/api/v1/"
        let serviceDateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter
        }()
        var date: Date = {
//            if let lastUpdate = UserDefaultsManager.lastUpdate {
//                return lastUpdate
//            }
            let calendar = Calendar.current
            let current = Date()
            let weekPrior = calendar.date(byAdding: .day, value: -7 , to: current)
            return weekPrior!
        }()
        let dateString = serviceDateFormatter.string(from: date)
        
        let state = Environment.current.state
        //TODO: add variable state to url
        let url = URL(string: baseUrl.appending("bills/?state=ga&search_window=term&updated_since=\(dateString)&fields=votes&type=bill"))!
        let resource = Resource<[String]>(url: url) { (json) -> [String]? in
            guard let dictionaries = json as? [[String: Any]] else { return nil }
            let votedBills = getIDsForVotedBills(dictionaries)
            return votedBills
        }
        return resource
    }
}

//extension Article {
//    static let allNewsArticlesResource = Resource<[NewsArticle]>(url: URL(string: "https://openstates.org/api/v1/")!) { (json) -> [NewsArticle]? in
//        guard let dictionaries = json as? [[String: Any]] else { return nil }
//        return dictionaries.flatMap(Article.init)
//    }
//}
