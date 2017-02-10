//
//  ActivityCell.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/10/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit

class ActivityCell: UITableViewCell {
 
    @IBOutlet var title: UILabel!
    @IBOutlet var token: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var activityDescription: UILabel!
    
    func setTokenFromActivityType(_ activityType: ActivityItem.ActivityType) {
        var tokenText = ""
        var tokenColor = UIColor.clear
        
        switch activityType {
        case .vote(let result):
            switch result {
            case .yea:
                tokenText = " Yea "
                tokenColor = UIColor(colorLiteralRed: 0.59, green: 0.86, blue: 0.27, alpha: 1)
            case .nay:
                tokenText = " Nay "
                tokenColor = UIColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: 1)
            case .other:
                tokenText = " Other "
                tokenColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            }
        default:
            break
        }
        
        token.text = tokenText
        token.backgroundColor = tokenColor
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width / 2
        token.layer.cornerRadius = 10
    }
}
