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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [0, 0]:
            self.performSegue(withIdentifier: "EditProfile", sender: nil)
        case [0,1]:
            logout()
        case [0,2]:
            if let number = URL(string: "tel://199") {
                UIApplication.shared.open(number, options: [:])
            }
        case [1, 0]:
            self.performSegue(withIdentifier: "EditArticles", sender: nil)
        default:
            print("Wrong selection")
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        self.performSegue(withIdentifier: "LoginView", sender: nil)
    }
    
}
