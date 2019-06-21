//
//  AdminSettingCellTableView.swift
//  Sanity
//
//  Created by Ali Hubail on 6/20/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

class AdminSettingCellTableView: UITableViewCell {
    
    
    // delegate
    weak var delegate: UserCellDelegate?
    // outlets
    @IBOutlet weak var qustion: UILabel!
    @IBOutlet weak var userType: UILabel!

}
