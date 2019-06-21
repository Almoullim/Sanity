//
//  SessionRecoredTableViewCell.swift
//  Sanity
//
//  Created by Ali Hubail on 6/17/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class SessionRecoredTableViewCell: UITableViewCell {
    
    // ID variable
    var sessionID: String!
    
    // outlet
    @IBOutlet weak var usersName: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var userOneImage: UIImageView!
    @IBOutlet weak var userTwoImage: UIImageView!
    weak var delegate: UserCellDelegate?

    
    
}
