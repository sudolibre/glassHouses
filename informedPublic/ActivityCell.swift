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
 
    @IBOutlet var date: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var token: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var activityDescription: UILabel!
    
    func applyViewData(_ viewData: ActivityCellViewData) {
        title.text = viewData.title
        activityDescription.text = viewData.activityDescription
        setTokenFromActivityType(viewData.activityType)
        if let image = viewData.avatarImage {
            avatarImage.image = image
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        date.text = dateFormatter.string(from: viewData.date)
    }
    
    private func setTokenFromActivityType(_ activityType: ActivityType) {
        var tokenText = ""
        var tokenColor = UIColor.clear
        
        switch activityType {
        case .vote(_, let result):
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
        case .news:
            tokenText = " News "
            tokenColor = UIColor(colorLiteralRed: 0.5, green: 0.0, blue: 1, alpha: 1)
            
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

struct ActivityCellViewData {
    let title: String
    let activityDescription: String
    let activityType: ActivityType
    var avatarImage: UIImage?
    var date: Date
}
