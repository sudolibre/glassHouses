//
//  glassHousesTests.swift
//  glassHousesTests
//
//  Created by Jonathon Day on 2/7/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import XCTest
@testable import glassHouses

class glassHousesTests: XCTestCase {
    
    func testNewsArticleParsing() {
        //tests 50 articles
        guard let url = Bundle(for: type(of: self)).url(forResource: "articlesJSON", withExtension: nil, subdirectory: "JSON") else {
            fatalError("articleJSON not found")
        }

        let jsonData = try? Data(contentsOf: url)
        XCTAssertNotNil(jsonData, "failed to create Data from json file")
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!, options: [])
        XCTAssertNotNil(jsonObject, "failed to create a foundation object from json data")
        let topLevelDictionary = jsonObject as? [String: Any]
        XCTAssertNotNil(topLevelDictionary, "failed to cast the top level json object from Any to a to dictionary")
        let jsonDictionaries = topLevelDictionary!["value"] as? [[String: Any]]
        XCTAssertNotNil(jsonDictionaries, "failed to cast the json object from Any to an array of dictionaries")
        let allNewsArticles = jsonDictionaries!.flatMap({NewsArticle.init(json: $0)})
        XCTAssertTrue(allNewsArticles.count == allNewsArticles.count, "failed to create all News Articles from all json dictionaries")
    }
    
    
    func testLegislationParsing() {
        // test 834 bills
        guard let urls = Bundle(for: type(of: self)).urls(forResourcesWithExtension: nil, subdirectory: "JSON/legislation") else {
            XCTFail("urls for test legislation could not be found")
            return
        }
        
        let allJSONData = urls.flatMap({try? Data(contentsOf: $0)})
        XCTAssertTrue(urls.count == allJSONData.count, "failed to create Data from all json files")
        let allJSONAny = allJSONData.flatMap({try? JSONSerialization.jsonObject(with: $0, options: [])})
        XCTAssertTrue(urls.count == allJSONAny.count, "failed to create foundation objects from all json data")
        let allJSONDict = allJSONAny.flatMap({$0 as? [String: Any]})
        XCTAssertTrue(urls.count == allJSONDict.count, "failed to cast all json objects from any to dictionary")
        let allLegislation = allJSONDict.flatMap({Legislation.init(json: $0)})
        XCTAssertTrue(urls.count == allLegislation.count, "failed to create Legislation from all json dictionaries")
    }
    
    func testLegislatorParsing() {
        // tests 237 legislators
        guard let urls = Bundle(for: type(of: self)).urls(forResourcesWithExtension: nil, subdirectory: "JSON/legislators") else {
            XCTFail("urls for test legislators could not be found")
            return
        }
        
        let allJSONData = urls.flatMap({try? Data(contentsOf: $0)})
        XCTAssertTrue(urls.count == allJSONData.count, "failed to create Data from all json files")
        let allJSONAny = allJSONData.flatMap({try? JSONSerialization.jsonObject(with: $0, options: [])})
        XCTAssertTrue(urls.count == allJSONAny.count, "failed to create foundation objects from all json data")
        let allJSONDict = allJSONAny.flatMap({$0 as? [String: Any]})
        XCTAssertTrue(urls.count == allJSONDict.count, "failed to cast all json objects from any to dictionary")
        let allLegislators = allJSONDict.flatMap({Legislator.init(json: $0)})
        XCTAssertTrue(urls.count == allLegislators.count, "failed to create legislators from all json dictionaries")
    }

}
