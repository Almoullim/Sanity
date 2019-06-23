//
//  AfterLoadViewController.swift
//  Sanity
//
//  Created by Ali on 5/26/19.
//  Copyright © 2019 Almoullim. All rights reserved.
// MainNavigator

import UIKit
import Firebase

class AfterLoadViewController: UIViewController {

    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("uid", isEqualTo: currentUser.uid)
                .getDocuments() { (querySnapshot, err) in
                    
                    if let userStatus = querySnapshot?.documents[0].data()["isActive"] as? Bool {
                        if userStatus == false {
                            try? Auth.auth().signOut()
                            self.performSegue(withIdentifier: "LoginView", sender: nil)
                        } else {
                            let userType = querySnapshot?.documents[0].data()["userType"]! as! String
                            
                            switch userType {
                            case "help-seeker":
                                self.performSegue(withIdentifier: "HelpSeeker", sender: nil)
                            case "volunteer":
                                self.performSegue(withIdentifier: "Volunteer", sender: nil)
                            case "doctor":
                                self.performSegue(withIdentifier: "Doctor", sender: nil)
                            case "admin":
                                self.performSegue(withIdentifier: "Admin", sender: nil)
                            default:
                                self.performSegue(withIdentifier: "LoginView", sender: nil)
                            }
                        }
                    } else {
                        self.performSegue(withIdentifier: "LoginView", sender: nil)
                    }
                    
            }
        } else {
            print("No login found")
            self.performSegue(withIdentifier: "LoginView", sender: nil)
        }
    }
    
    // Set the stuatus bar content to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
