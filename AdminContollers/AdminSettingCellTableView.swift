//
//  AdminSettingCellTableView.swift
//  Sanity
//
//  Created by Ali Hubail on 6/20/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
protocol AdminSettingDelegate: class {
    func segueWith(ID: String)
}

// this is an empty implementation of UserCellDelegate methods to allow them to be optional
extension AdminSettingDelegate {func segueWith(ID: String) {} }

class AdminSettingCellTableView: UITableViewCell {
    
    
    // delegate
    weak var delegate: AdminSettingDelegate?
    // outlets
    @IBOutlet weak var qustion: UILabel!
    @IBOutlet weak var userType: UILabel!
    
    var ID :String!
    @IBAction func requestButtonClicked(_ sender: Any) {
        delegate?.segueWith(ID: ID)
        
    }
}
