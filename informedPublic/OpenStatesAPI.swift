//
//  openStatesAPI.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/7/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

enum APIResponse {
    case success(Data)
    case networkError(HTTPURLResponse)
    case failure(Error)
}

class OpenStatesAPI {
    private static let baseUrl = "https://openstates.org/api/v1/"
    
    enum EndPoint {
        case findDistrict(lat: Double, long: Double)
        
        var urlComponent: String {
            switch self {
            case .findDistrict(lat: let lat, long: let long):
                return "legislators/geo/?lat=\(lat)&long=\(long)"
            }
        }
        
        var httpMethod: String {
            switch self {
            case .findDistrict:
                return "GET"
            }
        }
    }
    
    private static let session = URLSession.shared
    
    static func request(_ endpoint: EndPoint, completion: @escaping (APIResponse) -> ()) {
        let fullURL = URL(string: baseUrl + endpoint.urlComponent)!
        let request: URLRequest = {
            var req = URLRequest(url: fullURL)
            req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            req.httpMethod = endpoint.httpMethod
            return req
        }()
        
        session.dataTask(with: request) { (_data, _response, _error) in
            if let data = _data {
                completion(.success(data))
                return
            }
            
            if let response = _response as? HTTPURLResponse {
                completion(.networkError(response))
            }
            
            if let error = _error {
                completion(.failure(error))
            }
            
            }.resume()
    }
}
