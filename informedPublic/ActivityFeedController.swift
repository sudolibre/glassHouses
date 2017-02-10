//
//  ActivityFeedController.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit


class ActivityFeedController: UITableViewController {
    var lastUpdate: Date?
    var legislators: [Legislator]!
    var dataSource: ActivityFeedDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = ActivityFeedDataSource()
        tableView.dataSource = dataSource
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        
        
        
        //TOTO: DELETE MEEEEEEE
        legislators = [
        Legislator(jsonArray: [
            "full_name": "Pat Gardner",
            "district": "57",
            "leg_id": "GAL000113",
            "last_name": "Gardner",
            "party": "democratic",
            "photo_url": "http://www.house.ga.gov/SiteCollectionImages/GardnerPat109.jpg",
            "chamber": "lower",
            "active": true
            ])!,
            Legislator(jsonArray: [
                "full_name": "Nan Orrock",
                "district": "36",
                "leg_id": "GAL000038",
                "last_name": "Orrock",
                "party": "democratic",
                "photo_url": "http://www.senate.ga.gov/SiteCollectionImages/OrrockNan33.jpg",
                "chamber": "upper",
                "active": true
                ])!
        ]
        //DELELTELLETLELTELETLELTL
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        generateFeed()
    }
    
    func generateFeed() {
        OpenStatesAPI.fetchVotesForLegislators(legislators) { (activityItem) in
            self.dataSource.addItem(activityItem)
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected")
    }
}

class ActivityFeedDataSource: NSObject, UITableViewDataSource {
    var activityItems: [ActivityItem] = []
    
    func addItem(_ item: ActivityItem) {
        activityItems.append(item)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityCell
        let item = activityItems[indexPath.row]
        
        cell.title.text = item.legislator?.fullName
        cell.activityDescription.text = item.cellDescription
        cell.avatarImage.image = item.legislator?.photo
        cell.setTokenFromActivityType(item.activityType)
        return cell
    }
    
}
