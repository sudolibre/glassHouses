//
//  ActivityFeedController.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/9/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit
import QuickLook


class ActivityFeedController: UITableViewController {
    var lastUpdate: Date?
    var webservice: Webservice!
    var activityItemStore: ActivityItemStore!
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor.gray
        return spinner
    }()
    var legislators: [Legislator]!
    var dataSource = ActivityFeedDataSource()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataSource.activityItems.isEmpty {
            spinner.startAnimating()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateFeed()
        tableView.dataSource = dataSource
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        tableView.contentInset.top = statusBarHeight
        tableView.scrollIndicatorInsets.top = statusBarHeight
        
        view.addSubview(spinner)
        let centerXConstraint = view.centerXAnchor.constraint(equalTo: spinner.centerXAnchor)
        let centerYConstraint = view.centerYAnchor.constraint(equalTo: spinner.centerYAnchor)
        view.addConstraints([centerXConstraint, centerYConstraint])
    }
    
    
    func generateFeed() {
        activityItemStore.fetchActivityItems(legislators: legislators) { (activityItem) in
            DispatchQueue.main.async {
                self.dataSource.addItem(activityItem)
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[tableView.indexPathForSelectedRow!.row]
        switch item.activityType {
        case .vote(let legislation, _), .sponsor(let legislation):
            performSegue(withIdentifier: "anything", sender: nil)
        case .news(let article):
            let viewController: UIViewController = {
                let vc = UIViewController()
                let url = article.link
                let request = URLRequest(url: url as URL)
                let webView: UIWebView = {
                    let wv = UIWebView()
                    wv.loadRequest(request)
                    return wv
                }()
                vc.view = webView
                return vc
            }()
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showLegislation":
            let legislationVC = segue.destination as! LegislationDetailViewController
            legislationVC.legislation = sender as! Legislation!
            legislationVC.webservice = webservice
            legislationVC.dataSource = LegislationDetailDataSource(imageStore: dataSource.imageStore, legislation: sender as! Legislation)
        case "showNews":
            print("no thanks")
        default:
            fatalError("unexpected segue identifier")
        }
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
                if cell.legislatorID == legislator.id {
                    cell.avatarImage.image = image
                }
            })
        }
        return cell
    }
    
}
