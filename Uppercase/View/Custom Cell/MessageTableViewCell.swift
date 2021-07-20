//
//  MessageTableViewCell.swift
//  Uppercase
//
//  Created by The Techy Hub on 11/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var timeChat: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageView.layer.cornerRadius = 7
        messageView.layer.masksToBounds = true
        
        messageTextLabel.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
