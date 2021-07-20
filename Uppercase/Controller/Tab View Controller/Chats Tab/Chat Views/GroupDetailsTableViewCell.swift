//
//  GroupDetailsTableViewCell.swift
//  Uppercase
//
//  Created by The Techy Hub on 29/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class GroupDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var displayMemberImage: UIImageView!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var memberBioLabel: UILabel!
    @IBOutlet weak var memberAdminLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
