//
//  NewsSearchAPI.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/10/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import Crashlytics

class NewsSearchAPI {
    private static let session = URLSession.shared
    private static let key: String = {
        let path = Bundle.main.path(forResource: "API", ofType: "plist")!
        let plist = FileManager.default.contents(atPath: path)!
        let dictionary = try! PropertyListSerialization.propertyList(from: plist, options: .mutableContainers, format: nil) as! [String: String]
        return dictionary["BingKey"]!
    }()
    static private func getURLFor(legislator: Legislator) -> URL {
        let baseURL = "https://api.cognitive.microsoft.com/bing/v5.0/news/search?count=10&offset=0&mkt=en-us&safeSearch=Moderate&freshness=Month&q="
        let legislatorEncodedName = legislator.fullName.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let urlComponent = "%22\(legislatorEncodedName)%22%20\(legislator.chamber.description))"
        let fullURL = baseURL + urlComponent
        return URL(string: fullURL)!
    }
    
    
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
            req.addValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            return req
        }()

            session.dataTask(with: request) { (_data, _response, _error) in
                switch (_data, _response as! HTTPURLResponse?, _error) {
                case (.some(let data), .some(let response), _) where 200..<300 ~= response.statusCode:
                    completion(.success(data))
                case (_, .some(let response), _):
                    Answers.logCustomEvent(withName: "HTTP Error", customAttributes: [
                        "Code": response.statusCode
                        ])
                    completion(.networkError(response))
                case (_,_, .some(let error)):
                    Answers.logCustomEvent(withName: "System Error", customAttributes: [
                        "Description": error.localizedDescription
                        ])
                    completion(.failure(error))
                default:
                    Answers.logCustomEvent(withName: "Network Reponse Unexpectedly Reached Default Case", customAttributes: nil)
                }
                
            }.resume()
    }
}
    
