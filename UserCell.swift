//
//  VolunteerCell.swift
//  Sanity
//
//  Created by Ali on 3/31/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

protocol UserCellDelegate: class {
    func segueWith(user: String)
    func call(_ mobile: String)
}

// this is an empty implementation of UserCellDelegate methods to allow them to be optional
extension UserCellDelegate { func call(_ mobile: String) {}; func segueWith(user: String) {} }

class UserCell: UITableViewCell {

    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var username: String!
    var mobile: String?
    
    weak var delegate: UserCellDelegate?
    
    @IBAction func requestButtonClicked(_ sender: Any) {
        delegate?.segueWith(user: username)
        if let mobile = mobile {
            delegate?.call(mobile)
        }
        
    }
}
