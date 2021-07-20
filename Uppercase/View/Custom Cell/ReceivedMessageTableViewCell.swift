//
//  ReceivedMessageTableViewCell.swift
//  Uppercase
//
//  Created by The Techy Hub on 26/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class ReceivedMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var receivedMessageImage: UIImageView!
    @IBOutlet weak var receivedView: UIView!
    @IBOutlet weak var receivedTimeLabel: UILabel!
    @IBOutlet weak var receivedMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        receivedView.layer.cornerRadius = 7
        receivedView.layer.masksToBounds = true
        
        receivedMessageLabel.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
