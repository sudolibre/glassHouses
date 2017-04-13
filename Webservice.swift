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

final class WebService {
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { (data, _, _) in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(resource.parse(data))
        }.resume()
    }
}


extension Legislator {
    static let allLegislatorsResource = Resource<[Legislator]>(url: URL(string: "https://openstates.org/api/v1/")!) { (json) -> [Legislator]? in
        guard let dictionaries = json as? [[String: Any]] else { return nil }
        return dictionaries.flatMap(Legislator.init)
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
