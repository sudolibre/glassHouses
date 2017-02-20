//
//  informedPublicTests.swift
//  informedPublicTests
//
//  Created by Jonathon Day on 2/7/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import XCTest
@testable import informedPublic

class informedPublicTests: XCTestCase {
    
    func testArticleParsing() {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "articleJSON", ofType: nil) else {
            fatalError("articleJSON not found")
        }

        let url = URL(fileURLWithPath: pathString)
        let jsonData = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        let optionalResult = NewsArticle(json: json)
        XCTAssertNotNil(optionalResult)
        let result = optionalResult!
        XCTAssertTrue(
        result.title == "Sen. Parent gives insight on Healthcare, Casinos, Campus Carry ..." &&
        result.link == URL(string: "https://brookhavenpost.co/2017/02/10/sen-parent-gives-insight-on-healthcare-casinos-campus-carry-independent-redistricting-commission-during-town-hall/") &&
        result.publisher == "brookhavenpost.co" &&
        result.description == "2 days ago ... Senator Elena Parent fields questions from the audience at a February 9th Town \nHall Meeting in Decatur. TREY BENTON/THE POST. Decatur ..." &&
        result.imageURL == URL(string: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRED-0pTvU9N9HwhuH3CScrj6xLZeiHjPwfZ02EyzwTwHifQ_xAOrBItV0")
        )
    }
    
    func testLegislationParsing() {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "legislationJSON", ofType: nil) else {
            fatalError("articleJSON not found")
        }
        
        let url = URL(fileURLWithPath: pathString)
        let jsonData = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        let optionalResult = Legislation(json: json)
        XCTAssertNotNil(optionalResult)
        let result = optionalResult!
        XCTAssertTrue(
            result.title == "Family and Consumer Sciences; recognize" &&
            result.id == "SR 161" &&
            result.documentURL == URL(string: "http://www.legis.ga.gov/Legislation/20172018/164395.pdf") &&
            result.date == Date(timeIntervalSince1970: 1486482990.0)
        )
    }
    
    
    func testLegislatorParsing() {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "legislatorJSON", ofType: nil) else {
            fatalError("articleJSON not found")
        }
        
        let url = URL(fileURLWithPath: pathString)
        let jsonData = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        let optionalResult = Legislator(json: json)
        XCTAssertNotNil(optionalResult)
        let result = optionalResult!
        XCTAssertTrue(
            result.fullName == "Elena Parent" &&
            result.lastName == "Parent" &&
            result.district == 42 &&
            result.party == Legislator.Party.democratic &&
            result.chamber == Legislator.Chamber.upper &&
            result.photoURL == URL(string: "http://www.senate.ga.gov/SiteCollectionImages/ParentElena768.jpg") &&
            result.ID == "GAL000179"
            
        )
    }

}

//TOTO: DELETE MEEEEEEE
//        legislators = [
//        Legislator(json: [
//            "full_name": "Pat Gardner",
//            "district": "57",
//            "leg_id": "GAL000113",
//            "last_name": "Gardner",
//            "party": "democratic",
//            "photo_url": "http://www.house.ga.gov/SiteCollectionImages/GardnerPat109.jpg",
//            "chamber": "lower",
//            "active": true
//            ])!,
//            Legislator(json: [
//                "full_name": "Nan Orrock",
//                "district": "36",
//                "leg_id": "GAL000038",
//                "last_name": "Orrock",
//                "party": "democratic",
//                "photo_url": "http://www.senate.ga.gov/SiteCollectionImages/OrrockNan33.jpg",
//                "chamber": "upper",
//                "active": true
//                ])!
//        ]
//DELELTELLETLELTELETLELTL
