//
//  EventCellControllerTableViewCell.swift
//  Uppercase
//
//  Created by The Techy Hub on 03/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class EventCellControllerTableViewCell: UITableViewCell {

    @IBOutlet weak var eventPreview: UIImageView!
    @IBOutlet weak var titleEvent: UILabel!
    @IBOutlet weak var dateEvent: UILabel!
    @IBOutlet weak var locationEvent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
