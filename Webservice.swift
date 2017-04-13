//
//  Webservice.swift
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
            let something = resource.parse(data)
            completion(something)
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
    static let allLegislationsResource = Resource<[Legislation]>(url: URL(string: "https://openstates.org/api/v1/")!) { (json) -> [Legislation]? in
        guard let dictionaries = json as? [[String: Any]] else { return nil }
        return dictionaries.flatMap(Legislation.init)
    }
}

extension NewsArticle {
    static let allNewsArticlesResource = Resource<[NewsArticle]>(url: URL(string: "https://openstates.org/api/v1/")!) { (json) -> [NewsArticle]? in
        guard let dictionaries = json as? [[String: Any]] else { return nil }
        return dictionaries.flatMap(NewsArticle.init)
    }
}
