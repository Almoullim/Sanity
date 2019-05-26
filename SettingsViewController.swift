//
//  SettingsViewController.swift
//  Sanity
//
//  Created by Ali on 5/26/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UITableViewController {
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }


    @IBAction func logoutClicked(_ sender: Any) {
        try? Auth.auth().signOut()
        self.performSegue(withIdentifier: "LoginView", sender: nil)
    }
    
}
