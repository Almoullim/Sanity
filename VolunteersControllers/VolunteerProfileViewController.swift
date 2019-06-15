//
//  VolunteerProfileViewController.swift
//  Sanity
//
//  Created by Ali on 6/5/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class VolunteerProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var name: DesignableUILabel!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var ageValue: UILabel!
    @IBOutlet weak var callsCountValue: UILabel!
    @IBOutlet weak var specialityValue: UILabel!
    @IBOutlet weak var languageValue: UILabel!
    
    var username: String?
    var db: Firestore!
    var storage: Storage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("uid", isEqualTo: currentUser.uid)
                .getDocuments() { (querySnapshot, err) in
                    
                    if let data = querySnapshot?.documents[0].data() {
                        self.username = data["username"] as? String
                        self.name.text = data["name"] as? String
                        
                        if let location = data["location"] as? String {
                            self.location.text = location
                        }
                        
                        if let timestamp = data["created_at"] as? Timestamp {
                            self.userInfo.text = "Member since " + timeSince(timestamp: timestamp)
                        }
                        
                        if let date = data["dob"] as? Timestamp {
                            // Construct days since
                            let secondsSince = Int64(Date().timeIntervalSince1970) - date.seconds
                            self.ageValue.text = String((secondsSince / 86400) / 365)
                        }
                        
                        if let requestsCount = data["callsCount"] as? Int {
                            self.callsCountValue.text = String(requestsCount)
                        } else {
                            self.callsCountValue.text = "0"
                        }
                        
                        if let speciality = data["speciality"] as? String {
                            self.specialityValue.text = speciality
                        }
                        
                        if let language = data["language"] as? String {
                            self.languageValue.text = language
                        }
                        
                        let storageRef = self.storage.reference()
                        let imgRef = storageRef.child("images/" + self.username! + ".jpg")
                        
                        imgRef.downloadURL { (url, error) in
                            guard let downloadURL = url else { return }
                            print("image download started")
                            URLSession.shared.dataTask(with: downloadURL) { data, response, error in
                                let image = UIImage(data: data!)
                                DispatchQueue.main.async() {
                                    print("image download finished")
                                    self.profileImage.image = image
                                    self.backgroundImage.image = image
                                }
                                }.resume()
                        }
                    }
            }
            
        }
    }
    
    
}
