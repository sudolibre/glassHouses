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
            descriptionLabel.text! = "\(legislator.fullName)\n\(legislator.party)\nDistrict \(legislator.district)"
        }
    }
}
