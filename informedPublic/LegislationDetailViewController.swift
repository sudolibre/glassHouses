//
//  BillDetailViewController.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/17/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit

class LegislationDetailViewController: UIViewController, UICollectionViewDelegate {
    var legislation: Legislation!
    var dataSource: SponsorCollectionDataSource!
    //var dataSource: SponsorCollectionDataSource
    
    @IBOutlet var billStatusView: LegislationStatusView!
    @IBOutlet var billNameLabel: UILabel!
    @IBOutlet var billChamberLabel: UILabel!
    @IBOutlet var billDescriptionLabel: UILabel!
    @IBOutlet var sponsorCollectionView: UICollectionView!
    @IBOutlet var sponsorCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        //billStatusView.status = legislation.status
        billStatusView.status = .senate
        //DELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETE
        dataSource = SponsorCollectionDataSource(imageStore: ImageStore())
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "legislationJSON", ofType: nil) else {
            fatalError("articleJSON not found")
        }
        let url = URL(fileURLWithPath: pathString)
        let jsonData = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        let optionalResult = Legislation(json: json)
        legislation = optionalResult!
        //DELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETE
        
        sponsorCollectionView.dataSource = dataSource
        
        for id in legislation.sponsorIDs {
            OpenStatesAPI.fetchLegislatorByID(id: id) { (legislator) in
                self.dataSource.addLegislator(legislator)
                self.sponsorCollectionView.reloadData()
            }
        }
    }
    
}

class SponsorCollectionDataSource: NSObject, UICollectionViewDataSource {
    var sponsors: [Legislator] = []
    var imageStore: ImageStore
    
    subscript(index: Int) -> Legislator {
        return sponsors[index]
    }
    
    func addLegislator(_ legislator: Legislator) {
        sponsors.append(legislator)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sponsors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sponsorCell", for: indexPath) as! SponserCollectionCell
        let sponsor = sponsors[indexPath.row]
        cell.legislator = sponsor
        if let avatarImage = imageStore.getImage(forKey: sponsor.photoKey) {
            cell.avatarImageView.image = avatarImage
        } else {
            imageStore.fetchRemoteImage(forURL: sponsor.photoURL, completion: { (image) in
                self.imageStore.setImage(image, forKey: sponsor.photoKey)
                DispatchQueue.main.async {
                    cell.avatarImageView.image = image
                }
            })
        }
        return cell
    }
    
    init(imageStore: ImageStore) {
        self.imageStore = imageStore
    }
}
