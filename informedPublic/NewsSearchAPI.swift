//
//  NewsSearchAPI.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/10/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class NewsSearchAPI {
    static private func getURLFor(legislator: Legislator) -> URL {
        let baseURL = "https://www.googleapis.com/customsearch/v1?key=AIzaSyAH3dq06OZAe5kZjpnJdVCwpfJzcDuNmA0&cx=015255368873498272244:860ceyoviig&daterestrict=w1&sort=date&q="
        let legislatorEncodedName = legislator.fullName.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let suffixComponent = "%22\(legislatorEncodedName)%22%20\(legislator.chamber.description))%2Bmore%3Apagemap%3Ametatags-article_published_time"
        let fullURL = baseURL + suffixComponent
        return URL(string: fullURL)!
    }
    
    private static let session = URLSession.shared
    
    static func fetchNewsForLegislators(_ legislators: [Legislator], completion: @escaping ([ActivityItem]) -> ()) {
        for legislator in legislators {
            fetchNewsJSONForLegislator(legislator) { (response) in
                switch response {
                case .success(let data):
                    let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    let newsResults = dictionary["items"] as! [[String: Any]]
                    let newsArticles = newsResults.flatMap(NewsArticle.init)
                    let activityItems = newsArticles.map({ActivityItem(legislator: legislator, activityType: .news($0))})
                    completion(activityItems)
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
    
