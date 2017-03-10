//
//  openStatesAPI.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/7/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import Crashlytics

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
                return "bills/?state=ga&search_window=term&updated_since=\(dateString)&fields=votes&type=bill"
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
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    if let legislator = Legislator(json: json) {
                        completion(legislator)
                    }
                } catch {
                    Crashlytics.sharedInstance().recordCustomExceptionName("JSON Serialization Failure while fetching legislator", reason: "Legislator ID \(id), Preview: \(data.debugDescription)", frameArray: [])
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
                Crashlytics.sharedInstance().recordCustomExceptionName("JSON Mapping Failure: District Results", reason: "Preview: \(data.debugDescription)", frameArray: [])
                return []
        }
        
        let legislators = topLevelArray.flatMap(Legislator.init)
        return legislators
    }
    
    static func getNewBills(since date: Date, forEach completion: @escaping (String, [String: Any]) -> (), whenDone done: @escaping () -> ()) {
        request(.fetchNewBills(since: date)) { (response) in
            switch response {
            case .success(let data):
                do {
                    let recentBillsJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    let filteredBillIDs = getIDsForVotedBills(recentBillsJSON)
                    for id in filteredBillIDs {
                        getBillDetail(id: id) { (json) in
                            completion(id, json)
                        }
                    }
                } catch {
                    Crashlytics.sharedInstance().recordCustomExceptionName("JSON Serialization Failure while getting bills", reason: "Preview: \(data.debugDescription)", frameArray: [])
                }
                done()
            case .networkError(let response):
                print(response.debugDescription)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    private static func getBillDetail(id: String, completion: @escaping ([String: Any]) -> ()) {
        request(.fetchBillDetail(ID: id)) { (response) in
            switch response {
            case .success(let data):
                do {
                    let legislationJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    completion(legislationJSON)
                } catch {
                    Crashlytics.sharedInstance().recordCustomExceptionName("JSON Serialization Failure while getting bill detail", reason: "Bill ID \(id), Preview: \(data.debugDescription)", frameArray: [])
                }
            case .networkError(let response):
                print(response.debugDescription)
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
