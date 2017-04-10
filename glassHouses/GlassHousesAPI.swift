//
//  GlassHousesServer.swift
//  GlassHouses
//
//  Created by Jonathon Day on 4/3/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import Crashlytics


struct GlassHousesAPI {
    private static let baseURL = "http://104.131.31.61:80/"
    
    private static let session = URLSession.shared
    
    enum Endpoint {
        case register(token: String, legislators: [Legislator])
        
        var URLComponent: String {
            switch self {
            case .register:
                return "register"
            }
        }
        
        var httpMethod: String {
            switch self {
            case .register:
                return "POST"
            }
        }
        
        var headers: [String: String] {
            switch self {
            case .register:
                return ["Content-Type": "application/json"]
            }
        }
        
        var body: Data? {
            switch self {
            case .register(let token, let legislators):
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
                let bodyData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
                return bodyData
            }
        }
        
    }
    
    static func hitEndpoint(_ endpoint: Endpoint, completion: @escaping (APIResponse) -> ()) {
        let request: URLRequest = {
            let url = URL(string: baseURL + endpoint.URLComponent)!
            var req = URLRequest(url: url)
            req.httpMethod = endpoint.httpMethod
            req.httpBody = endpoint.body
            endpoint.headers.forEach({ (key: String, value: String) in
                req.setValue(value, forHTTPHeaderField: key)
            })
            return req
        }()
        
        session.dataTask(with: request) { (data, response, error) in
            switch (data, response as! HTTPURLResponse?, error) {
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
