//
//  NewsSearchAPI.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/10/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class NewsSearchAPI {
    static private func getURLFor(legislator: Legislator) -> URL {
        let baseURL = "https://api.cognitive.microsoft.com/bing/v5.0/news/search?count=10&offset=0&mkt=en-us&safeSearch=Moderate&freshness=Month&q="
        let legislatorEncodedName = legislator.fullName.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let urlComponent = "%22\(legislatorEncodedName)%22%20\(legislator.chamber.description))"
        let fullURL = baseURL + urlComponent
        return URL(string: fullURL)!
    }
    
    private static let session = URLSession.shared
    
    static func fetchNewsForLegislators(_ legislators: [Legislator], completion: @escaping ((Legislator,[[String: Any]])) -> ()) {
        for legislator in legislators {
            fetchNewsJSONForLegislator(legislator) { (response) in
                switch response {
                case .success(let data):
                    do {
                    let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    let newsResults = dictionary["value"] as! [[String: Any]]
                    completion((legislator, newsResults))
                    } catch {
                        fatalError("Failed to turn JSON into object while fetching news: \(error)")
                    }
                case .networkError(let response):
                    print(response.debugDescription)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private static func fetchNewsJSONForLegislator(_ legislator: Legislator, completion: @escaping (APIResponse) -> ()) {
        let url = getURLFor(legislator: legislator)
        let request: URLRequest = {
            var req = URLRequest(url: url)
            req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            req.httpMethod = "GET"
            req.addValue("4736b3e01ee14403a25247f38ae243bd", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            return req
        }()
        
        session.dataTask(with: request) { (_data, _response, _error) in
            if let data = _data {
                completion(.success(data))
                return
            }
            
            if let response = _response as? HTTPURLResponse {
                completion(.networkError(response))
                print(response.statusCode)
            }
            
            if let error = _error {
                completion(.failure(error))
                print(error.localizedDescription)
            }
            
            }.resume()
    }
}
    
