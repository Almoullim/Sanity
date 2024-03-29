//
//  AdminSettingsViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/18/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AdminSettingsViewController: UITableViewController {
    
    // firebase connection
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // firebase api code
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [1, 0]:
           self.performSegue(withIdentifier: "EditProfile", sender: nil)
        case [1,1]:
            logout()
        case [0, 0]:
            self.performSegue(withIdentifier: "Articles", sender: nil)
        case [0, 1]:
            self.performSegue(withIdentifier: "Qustions", sender: nil)
       
        default:
            print("Wrong selection")
        }
    }
    
    func logout() {
        // lougout 
        try? Auth.auth().signOut()
       self.performSegue(withIdentifier: "LoginView", sender: nil)
    }
}
