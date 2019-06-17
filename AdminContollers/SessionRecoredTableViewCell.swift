//
//  SessionRecoredTableViewCell.swift
//  Sanity
//
//  Created by Ali Hubail on 6/17/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

class SessionRecoredTableViewCell: UITableViewCell {

    @IBOutlet weak var UserOneImage: DesignableUIImageView!
    @IBOutlet weak var UserTwoImage: DesignableUIImageView!
    @IBOutlet weak var UsersName: UILabel!
    @IBOutlet weak var TimeSince: UILabel!
    @IBOutlet weak var SessionIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
}
