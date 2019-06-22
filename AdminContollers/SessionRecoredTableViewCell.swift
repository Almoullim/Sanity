//
//  SessionRecoredTableViewCell.swift
//  Sanity
//
//  Created by Ali Hubail on 6/17/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase


protocol SessionRecoredCellDelegate: class {
    func segueWith(ID: String)
}

// this is an empty implementation of UserCellDelegate methods to allow them to be optional
extension SessionRecoredCellDelegate {func segueWith(ID: String) {} }

class SessionRecoredTableViewCell: UITableViewCell {
    
    // ID variable
    var ID: String!
    
    // outlet
    @IBOutlet weak var usersName: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var userOneImage: UIImageView!
    @IBOutlet weak var userTwoImage: UIImageView!
    weak var delegate: SessionRecoredCellDelegate?

    @IBAction func requestButtonClicked(_ sender: Any) {
        delegate?.segueWith(ID: ID)
        
    }
    
    
}
