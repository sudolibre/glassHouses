//
//  WebService.swift
//  GlassHouses
//
//  Created by Jonathon Day on 4/13/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import CoreData

enum HttpMethod<Body> {
    case get
    case post(Body)
    
    var method: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}

struct Resource<A> {
    let url: URL
    let httpMethod: HttpMethod<Any>
    let parse: (Data) -> A?
}

extension Resource {
    init(url: URL, method: HttpMethod<Any> = .get, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.httpMethod = method
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

extension URLRequest {
    init<A>(_ resource: Resource<A>) {
        self.init(url: resource.url)
        self.httpMethod = resource.httpMethod.method
        if case .post(let body) = resource.httpMethod {
            self.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}

final class Webservice {
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        let request = URLRequest(resource)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            let urlResponse = response as! HTTPURLResponse
            if let error = error {
                print(error)
            }
            let code = urlResponse.statusCode
            completion(resource.parse(data))
            }.resume()
    }
}


extension Legislator {
    typealias Coordinates = (lat: Double,long: Double)
    
    static func fromJSON(_ json: [String: Any], follow: Bool = false, into context: NSManagedObjectContext) -> Legislator? {
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
            legislator.following = follow
        }
        return legislator
    }
    
    static func allLegislatorsResource(at coordinates: Coordinates, into context: NSManagedObjectContext) -> Resource<[Legislator]> {
        let baseUrl = "https://openstates.org/api/v1/"
        let url = URL(string: baseUrl.appending("legislators/geo/?lat=\(coordinates.lat)&long=\(coordinates.long)"))!
        let resource = Resource<[Legislator]>(url: url) { (json) -> [Legislator]? in
            guard let dictionaries = json as? [[String: Any]] else { return nil }
            return dictionaries.flatMap({Legislator.fromJSON($0, follow: true, into: context)})
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
        guard let id = json.getStringForKey("id"),
            let documentVersions = json.getArrayOfDictForKey("versions"),
            let recentVersion = documentVersions.last,
            let documentURLString = recentVersion.getStringForKey("url"),
            let documentURL = URL(string: documentURLString),
            let title = json.getStringForKey("title"),
            let actionDates = json.getDictForKey("action_dates"),
            let dateString = actionDates.getStringForKey("last"),
            let date = dateFormatter.date(from: dateString),
            let sponsorArray = json.getArrayOfDictForKey("sponsors"),
            let votesArray = json.getArrayOfDictForKey("votes"),
            let yesVotesArray = votesArray.first?.getArrayOfDictForKey("yes_votes"),
            let noVotesArray = votesArray.first?.getArrayOfDictForKey("no_votes"),
            let otherVotesArray = votesArray.first?.getArrayOfDictForKey("other_votes") else {
                return nil
        }
        
        let description = json.getStringForKey("+description") ?? json.getStringForKey("summary") ?? "No summary available"
        
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
        let status: Status = {
            let actionString = json["signed"] as? String ?? json["passed_upper"] as? String ?? json["passed_lower"] as? String
            return Status(action: actionString)
        }()
       
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
        guard let state = Environment.current.state else { fatalError("state not found")
        }

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
        let date: Date = {
            //TODO: re-enable last update check
//            if let lastUpdate = UserDefaultsManager.lastUpdate {
//                return lastUpdate
//            }
            let calendar = Calendar.current
            let current = Date()
            let weekPrior = calendar.date(byAdding: .day, value: -7 , to: current)
            return weekPrior!
        }()
        let dateString = serviceDateFormatter.string(from: date)
        
        let url = URL(string: baseUrl.appending("bills/?state=\(state)&search_window=term&updated_since=\(dateString)&fields=votes&type=bill"))!
        let resource = Resource<[String]>(url: url) { (json) -> [String]? in
            guard let dictionaries = json as? [[String: Any]] else { return nil }
            let votedBills = getIDsForVotedBills(dictionaries)
            return votedBills
        }
        return resource
    }
}

extension Article {
    static func fromJSON(_ json: [String: Any], legislator: Legislator, into context: NSManagedObjectContext) -> Article? {
        guard let title = json["name"] as? String,
            let description = json["description"] as? String,
            let linkString = json["url"] as? String,
            let link = NSURL(string: linkString),
            let publisher = json["publisher"] as? String,
            let dateInterval = json["date"] as? Double else {
                return nil
        }
        let date = NSDate.init(timeIntervalSince1970: dateInterval)
        
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        let predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.predicate = predicate
        var fetchedArticle: [Article]?
        context.performAndWait {
            fetchedArticle = try? fetchRequest.execute()
        }
        if let existingArticle = fetchedArticle?.first {
            return existingArticle
        }
        
        var article: Article!
        ActivityItemStore.context.performAndWait {
            article = Article(context: ActivityItemStore.context)
            article.title = title
            article.publisher = publisher
            article.articleDescription = description
            article.link = link as NSURL
            article.date = date as NSDate
            article.legislatorID = legislator.id
            if let imageDictionary = json["image"] as? [String: Any],
                let thumbnailDictionary = imageDictionary["thumbnail"] as? [String: Any],
                let imageURLString = thumbnailDictionary["contentURL"] as? String,
                let _imageURL = URL(string: imageURLString) {
                article.imageURL = _imageURL as NSURL
            }
        }
        
        return article
    }

    static func allArticlesResource(for legislators: [Legislator], into context: NSManagedObjectContext) -> Resource<[Article]> {
        //TODO: switch back to productin server
        //let url = URL(string: "http://104.131.31.61:80/register")!
        let url = URL(string: "http://192.168.1.239:8080/register")!
        let token = UserDefaultsManager.getAPNSToken() ?? ""
        let arrayOfLegislatorInfo: [[String: String]] = legislators.map({ (legislator) -> [String: String] in
            [
                "fullname": legislator.fullName,
                "chamber": legislator.chamber.rawValue
            ]
        })
        let jsonDictionary: [String: Any] = [
            "token": token,
            "legislators": arrayOfLegislatorInfo
        ]
        let method = HttpMethod<Any>.post(jsonDictionary)
        let parseJSON = { (json: Any) -> [Article]? in
            guard let dictionary = json as? [String: Any] else { return nil }
            let articleGroups = legislators.flatMap({ (legislator) -> [Article]? in
                let articlesJSON = dictionary[legislator.fullName] as? [[String : Any]]
                return articlesJSON?.flatMap({Article.fromJSON($0, legislator: legislator, into: context)})
            })
            return articleGroups.flatMap({$0})
        }
        return Resource<[Article]>(url: url, method: method, parseJSON: parseJSON)
    }
}
