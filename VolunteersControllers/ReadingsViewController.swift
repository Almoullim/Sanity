//
//  ReadingsViewController.swift
//  Sanity
//
//  Created by Ali on 6/5/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class ReadingsViewController: UITableViewController {

    var db: Firestore!
    
    @IBOutlet weak var ReadingsTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var articles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
