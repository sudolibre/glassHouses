//
//  WebService.swift
//  GlassHouses
//
//  Created by Jonathon Day on 4/13/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

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
            completion(resource.parse(data))
            }.resume()
    }
}


extension Legislator {
    static func allLegislatorsResource(at coordinates: Coordinates) -> Resource<[Legislator]> {
        let baseUrl = "https://openstates.org/api/v1/"
        let url = URL(string: baseUrl.appending("legislators/geo/?lat=\(coordinates.lat)&long=\(coordinates.long)"))!
        let resource = Resource<[Legislator]>(url: url) { (json) -> [Legislator]? in
            guard let dictionaries = json as? [[String: Any]] else { return nil }
            return dictionaries.flatMap(Legislator.init)
        }
        return resource
    }
    
    static func legislatorResource(withID id: String) -> Resource<Legislator> {
        let baseUrl = URL(string: "https://openstates.org/api/v1/")!
        let url = baseUrl.appendingPathComponent("legislators/\(id)")
        let resource = Resource<Legislator>(url: url) { (json) -> Legislator? in
            guard let dictionary = json as? [String: Any] else { return nil }
            return Legislator(json: dictionary)
        }
        return resource
    }
}




extension Legislation {
    static func legislationResource(withID id: String) -> Resource<Legislation> {
        let baseUrl = "https://openstates.org/api/v1/"
        let url = URL(string: baseUrl.appending("bills/\(id)"))!
        let resource = Resource<Legislation>(url: url) { (json) -> Legislation? in
            guard let dictionary = json as? [String: Any] else { return nil }
            return Legislation(json: dictionary)
        }
        return resource

    }
    static func recentLegislationIDsResource() -> Resource<[String]> {
        func getIDsForVotedBills(_ array: [[String: Any]]) -> [String] {
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
    
    
    
    static func legislatorResource(withID id: String) -> Resource<Legislator> {
        let baseUrl = URL(string: "https://openstates.org/api/v1/")!
        let url = baseUrl.appendingPathComponent("legislators/\(id)")
        let resource = Resource<Legislator>(url: url) { (json) -> Legislator? in
            guard let dictionary = json as? [String: Any] else { return nil }
            return Legislator(json: dictionary)
        }
        return resource
    }
}

extension NewsArticle {
    static let allNewsArticlesResource = Resource<[NewsArticle]>(url: URL(string: "https://openstates.org/api/v1/")!) { (json) -> [NewsArticle]? in
        guard let dictionaries = json as? [[String: Any]] else { return nil }
        return dictionaries.flatMap(NewsArticle.init)
    }
}
