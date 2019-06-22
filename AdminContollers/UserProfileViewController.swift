//
//  UserProfileViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/15/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {

    // outlets
    @IBOutlet weak var UserImage: UIImageView!
    @IBOutlet weak var EditButton: UIBarButtonItem!
    @IBOutlet weak var UserName: DesignableUILabel!
    @IBOutlet weak var MemberSince: UILabel!
    @IBOutlet weak var Location: UILabel!
    @IBOutlet weak var Age: UILabel!
    @IBOutlet weak var CallsNumber: UILabel!
    @IBOutlet weak var CallsLable: UILabel!
    @IBOutlet weak var Speciality: UILabel!
    @IBOutlet weak var SpecialityLable: UILabel!
    @IBOutlet weak var Language: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // pass info
    var username: String?
    var userType: String?
    
    // firebase connection
    var db: Firestore!
    var storage: Storage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // firebase api code
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // get user info and assign to outlets
        if let currentUser = username {
            db.collection("users").whereField("username", isEqualTo: currentUser)
                .getDocuments() { (querySnapshot, err) in
                    
                    if let data = querySnapshot?.documents[0].data() {
                        self.userType = data["userType"] as? String
                        if self.userType == "help-seeker" {
                            self.CallsLable.text = "Requests count"
                            self.SpecialityLable.text = "Issue"
                        }
                        self.username = data["username"] as? String
                        self.UserName.text = data["name"] as? String
                        if let status = data["isActive"] as? Bool {
                            if status == true {
                                self.statusLabel.text = "Active"
                            }else{
                                self.statusLabel.text = "Pending"
                            }
                        }
                        if let location = data["location"] as? String {
                            self.Location.text = location
                        }
                        if let timestamp = data["created_at"] as? Timestamp {
                            self.MemberSince.text = "Member since " + timeSince(timestamp: timestamp)
                        }
                        if let date = data["dob"] as? Timestamp {
                            // Construct days since
                            let secondsSince = Int64(Date().timeIntervalSince1970) - date.seconds
                            self.Age.text = String((secondsSince / 86400) / 365)
                        }
                        if let requestsCount = data["requestsCount"] as? Int {
                            self.CallsNumber.text = String(requestsCount)
                        } else {
                            self.CallsNumber.text = "0"
                        }
                        if self.userType == "help-seeker" {
                        if let issue = data["issue"] as? String {
                            self.Speciality.text = issue
                        }
                        }else{
                            if let issue = data["speciality"] as? String {
                                self.Speciality.text = issue
                            }
                        }
                        
                        if let language = data["language"] as? String {
                            self.Language.text = language
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
                                    self.UserImage.image = image
                                    self.backImage.image = image
                                }
                                }.resume()
                        }
                    }
            }
        }
            
    }
    
    
    @IBAction func unwindToUsersProfile(segue:UIStoryboardSegue) { }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editUser" {
            if segue.destination is EditUserProfileViewController
            {
                let view = segue.destination as? EditUserProfileViewController
                view?.username = self.username
                view?.userType = self.userType
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
