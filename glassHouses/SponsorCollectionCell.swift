//
//  sponserCollectionCell.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/18/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit

class SponserCollectionCell: UICollectionViewCell {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    
    var legislator: Legislator! {
        didSet {
            let partyText = legislator.party?.description ?? "Loading..."
            let districtText: String = {
                guard legislator.district > 0 else {
                    return " "
                }
                return "District \(legislator.district.description)"
            }()
            descriptionLabel.text! = "\(legislator.fullName)\n\(partyText)\n \(districtText)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
