//
//  ActivityFeedController.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit
import QuickLook


class ActivityFeedController: UITableViewController {
    var lastUpdate: Date?
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var legislators: [Legislator]! {
        didSet {
            generateFeed()
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
        }
    }
    var dataSource = ActivityFeedDataSource()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if dataSource.activityItems.isEmpty {
            spinner.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        let centerXConstraint = view.centerXAnchor.constraint(equalTo: spinner.centerXAnchor)
        let centerYConstraint = view.centerYAnchor.constraint(equalTo: spinner.centerYAnchor)
        
        view.addConstraints([centerXConstraint, centerYConstraint])
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        spinner.color = UIColor.gray
        
        
        
        
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
        
        
        
        
    }
    
    
    func generateFeed() {
        ActivityItemStore.fetchActivityItems(legislators: legislators) { (activityItem) in
            DispatchQueue.main.async {
                self.dataSource.addItem(activityItem)
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let item = dataSource[tableView.indexPathForSelectedRow!.row]
        var url: URL {
            switch item.activityType {
            case .vote(let legislation, _), .sponsor(let legislation):
                return legislation.documentURL
            case .news(let article):
                return article.link as! URL
            case .legislationLifecycle:
                fatalError("not implemented yet")
            }
        }
        let request = URLRequest(url: url)
        let webView = segue.destination.view as? UIWebView
        webView?.loadRequest(request)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

class ActivityFeedDataSource: NSObject, UITableViewDataSource {
    var imageStore = ImageStore()
    var activityItems: [ActivityItem] = []
    
    subscript(index: Int) -> ActivityItem {
        return activityItems[index]
    }
    
    func addItem(_ item: ActivityItem) {
        activityItems.append(item)
        activityItems.sort(by: {$0.0.date > $0.1.date})
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityCell
        let item = activityItems[indexPath.row]
        cell.applyViewData(item.activityCellViewData)
        let legislator = item.legislator
        if let avatarImage = imageStore.getImage(forKey: legislator.photoKey) {
            cell.avatarImage.image = avatarImage
        } else {
            imageStore.fetchRemoteImage(forURL: legislator.photoURL, completion: { (image) in
                self.imageStore.setImage(image, forKey: legislator.photoKey)
                if cell.legislatorID == legislator.ID {
                    cell.avatarImage.image = image
                }
            })
        }
        return cell
    }
    
}
