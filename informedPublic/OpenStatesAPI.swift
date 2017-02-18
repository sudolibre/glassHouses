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

enum VoteResult: CustomStringConvertible {
    case yea
    case nay
    case other
    
    var description: String {
        switch self {
        case .yea:
            return "FOR"
        case .nay:
            return "AGAINST"
        case .other:
            return "OTHER for"
        }
    }
}

class OpenStatesAPI {
    private static let baseUrl = "https://openstates.org/api/v1/"
    
    enum EndPoint {
        case findDistrict(lat: Double, long: Double)
        case fetchNewBills(since: Date)
        case fetchBillDetail(ID: String)
        case fetchLegislator(ID: String)
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }
        
        var urlComponent: String {
            switch self {
            case .findDistrict(lat: let lat, long: let long):
                return "legislators/geo/?lat=\(lat)&long=\(long)"
            case .fetchNewBills(since: let date):
                let dateString = dateFormatter.string(from: date)
                return "bills/?state=ga&search_window=term&updated_since=\(dateString)&fields=votes"
            case .fetchBillDetail(ID: let id):
                return "bills/\(id)"
            case .fetchLegislator(ID: let id):
                return "legislators/\(id)"
            }
        }
        
        var httpMethod: String {
            switch self {
            case .findDistrict, .fetchNewBills, .fetchBillDetail, .fetchLegislator:
                return "GET"
            }
        }
    }
    
    static internal func fetchLegislatorsByID(ids: [String], completion: @escaping ([Legislator]) -> ()) {
        
        var legislators: [Legislator] = []
                
        for id in ids {
            fetchLegislatorByID(id: id, completion: { (legislator) in
                legislators.append(legislator)
                if legislators.count ==  ids.count {
                    completion(legislators)
                }
            })
        }
    }
    
    static internal func fetchLegislatorByID(id: String, completion: @escaping (Legislator) -> ()) {
        request(.fetchLegislator(ID: id), completion: { (response) in
            switch response {
            case .success(let data):
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let legislator = Legislator(json: json) {
                        completion(legislator)
                }
            case .networkError(let response):
                print(response.description)
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        })
    }
    
    static internal func parseDistrictResults(_ data: Data) -> [Legislator] {
        guard let foundationObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let topLevelArray = foundationObject as? [[String: Any]] else {
                fatalError("Unexpected top level item in district search JSON. Expecting Array")
        }
        
        let legislators = topLevelArray.flatMap(Legislator.init)
        return legislators
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
    
    static func getNewBills(since date: Date, forEach completion: @escaping (String, [String: Any]) -> (), whenDone done: @escaping () -> ()) {
        request(.fetchNewBills(since: date)) { (response) in
            switch response {
            case .success(let data):
                let recentBillsJSON = try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                let filteredBillIDs = getIDsForVotedBills(recentBillsJSON)
                for id in filteredBillIDs {
                    getBillDetail(id: id) { (json) in
                        completion(id, json)
                    }
                }
                done()
            case .networkError(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    private static func getBillDetail(id: String, completion: @escaping ([String: Any]) -> ()) {
        request(.fetchBillDetail(ID: id)) { (response) in
            switch response {
            case .success(let data):
                let legislationJSON = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                completion(legislationJSON)
            case .networkError(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func getIDsForVotedBills(_ array: [[String: Any]]) -> [String] {
        let filteredArray = array.filter({ (dictionary) -> Bool in
            let votesArray = dictionary["votes"] as! [[String: Any]]
            return !votesArray.isEmpty
        })
        return filteredArray.map({ $0["id"] as! String})
    }
    
}
