//
//  GroupTableViewCell.swift
//  Uppercase
//
//  Created by The Techy Hub on 10/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupPictureImage: UIImageView!
    @IBOutlet weak var groupLastUpdatedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
