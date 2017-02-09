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
    case yea(voterDescription: String)
    case nay(voterDescription: String)
    case other(voterDescription: String)
    
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
        case fetchVotesForLegislators//(voterDescriptions: [String])
        case fetchBillDetail(ID: String)
        
        var urlComponent: String {
            switch self {
            case .findDistrict(lat: let lat, long: let long):
                return "legislators/geo/?lat=\(lat)&long=\(long)"
            case .fetchVotesForLegislators:
                return "bills/?state=ga&search_window=term&updated_since=2017-02-02&fields=votes"
            case .fetchBillDetail(ID: let id):
                return "bills/\(id)"
            }
        }
        
        var httpMethod: String {
            switch self {
            case .findDistrict, .fetchVotesForLegislators, .fetchBillDetail:
                return "GET"
            }
        }
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
    
    static func fetchVotesForLegislators(_ legislators: [Legislator], completion: @escaping (ActivityItem) -> ()) {
        request(.fetchVotesForLegislators) { (response) in
            switch response {
            case .success(let data):
                let recentBillsJSON = try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                let filteredBillIDs = getIDsForVotedBills(recentBillsJSON)
                for id in filteredBillIDs {
                    getVoteForBill(id: id, legislators: legislators, completion: completion)
                }
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
    
    
    static func getVoteForBill(id: String, legislators: [Legislator], completion: @escaping (ActivityItem) -> ()) {
        request(.fetchBillDetail(ID: id)) { (response) in
            switch response {
            case .success(let data):
                let legislationJSON = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let legislation = Legislation(json: legislationJSON)
                let votes = legislationJSON["votes"] as! [[String:Any]]
                
                for i in votes {
                    let yesVotes = i["yes_votes"] as! [[String:Any]]
                    let noVotes = i["no_votes"] as! [[String:Any]]
                    let otherVotes = i["no_votes"] as! [[String:Any]]
                    let yesNames = yesVotes.map({$0["name"] as! String})
                    let noNames = noVotes.map({$0["name"] as! String})
                    let otherNames = otherVotes.map({$0["name"] as! String})
                    var voteCount = 0 {
                        didSet {
                            if voteCount == legislators.count {
                                return
                            }
                        }
                    }
                    
                    for yesName in yesNames {
                        for legislator in legislators {
                            if legislator.voterDescription == yesName {
                                let activityItem = ActivityItem(legislation: legislation, legislator: legislator, activityType: .vote(.yea(voterDescription: yesName)))
                                completion(activityItem)
                                voteCount += 1
                            }
                        }
                    }
                    
                    for noName in noNames {
                        for legislator in legislators {
                            if legislator.voterDescription == noName {
                                let activityItem = ActivityItem(legislation: legislation, legislator: legislator, activityType: .vote(.nay(voterDescription: noName)))
                                completion(activityItem)
                                voteCount += 1
                                
                            }
                        }
                    }
                    
                    for otherName in otherNames {
                        for legislator in legislators {
                            if legislator.voterDescription == otherName {
                                let activityItem = ActivityItem(legislation: legislation, legislator: legislator, activityType: .vote(.other(voterDescription: otherName)))
                                completion(activityItem)
                                voteCount += 1
                            }
                        }
                    }
                }
                
            case .networkError(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
