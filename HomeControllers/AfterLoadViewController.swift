//
//  AfterLoadViewController.swift
//  Sanity
//
//  Created by Ali on 5/26/19.
//  Copyright © 2019 Almoullim. All rights reserved.
// MainNavigator

import UIKit
import Firebase
import LocalAuthentication

class AfterLoadViewController: UIViewController {

    var db: Firestore!
    var context = LAContext()

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
                            
            // log in using face ID
            // https://developer.apple.com/documentation/localauthentication/logging_a_user_into_your_app_with_face_id_or_touch_id
                            self.context = LAContext()
                            self.context.localizedCancelTitle = "Login using user name and password"
                            var error: NSError?
                            if self.context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                                
                                let reason = "Log in to your account"
                                self.context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                                    if success {
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
                                    } else {
                                        print(error?.localizedDescription ?? "Failed to authenticate")
                                        try? Auth.auth().signOut()
                                        self.performSegue(withIdentifier: "LoginView", sender: nil)

                                    }
                                }
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
