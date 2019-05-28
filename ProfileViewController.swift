//
//  ProfileViewController.swift
//  Sanity
//
//  Created by Ali on 5/28/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var name: DesignableUILabel!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var ageValue: UILabel!
    @IBOutlet weak var requestsCountValue: UILabel!
    @IBOutlet weak var issueValue: UILabel!
    @IBOutlet weak var languageValue: UILabel!
    
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
                    
                    if let data = querySnapshot?.documents[0].data() {
                        self.name.text = data["name"] as? String
                        self.location.text = data["location"] as? String
                        
                        if let timestamp = data["created_at"] as? Timestamp {
                            self.userInfo.text = "Member since " + timeSince(timestamp: timestamp)
                        }
                        
                        if let date = data["dob"] as? Timestamp {
                            // Construct days since
                            let secondsSince = Int64(Date().timeIntervalSince1970) - date.seconds
                            self.ageValue.text = String((secondsSince / 86400) / 365)
                        }
                        
                        self.requestsCountValue.text = String((data["requestsCount"] as? Int)!)
                        self.issueValue.text = data["issue"] as? String
                        self.languageValue.text = data["language"] as? String
                    }
            }

        }
    }
    
    
}
