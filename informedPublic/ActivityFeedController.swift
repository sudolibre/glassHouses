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
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
        let item = activityItems[indexPath.row]
        
        cell.textLabel?.text = item.legislator?.fullName
        cell.detailTextLabel?.text = item.cellDescription
        cell.imageView?.image = item.legislator?.photo
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
        
        return cell
    }
    
}
