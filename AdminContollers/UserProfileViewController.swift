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

    
    @IBOutlet weak var UserImage: UIImageView!
    @IBOutlet weak var SaveEditButton: UIBarButtonItem!
    @IBOutlet weak var UserName: DesignableUILabel!
    @IBOutlet weak var MemberSince: UILabel!
    @IBOutlet weak var Location: UILabel!
    @IBOutlet weak var Age: UILabel!
    @IBOutlet weak var CallsNumber: UILabel!
    @IBOutlet weak var CallsLable: UILabel!
    @IBOutlet weak var Speciality: UILabel!
    @IBOutlet weak var SpecialityLable: UILabel!
    @IBOutlet weak var Language: UILabel!
    @IBOutlet weak var isAvtive: UISwitch!
    
    var username: String?
    var db: Firestore!
    var storage: Storage!
    var userType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let currentUser = username {

            db.collection("users").whereField("username", isEqualTo: username!)
                .getDocuments() { (querySnapshot, err) in
                    
                    if let data = querySnapshot?.documents[0].data() {
                        
                        self.userType = data["userType"] as? String
                        if self.userType == "help-seeker" {
                            self.CallsLable.text = "Requests count"
                            self.SpecialityLable.text = "Issue"
                            
                        } else if self.userType == "doctor" {
                            self.SaveEditButton.title = "edit"
                            
                        }
                        
                        self.username = data["username"] as? String
                        self.UserName.text = data["name"] as? String
                        self.isAvtive.isOn = (data["name"] as? Bool)!

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
                                }
                                }.resume()
                        }
                    }
            }
        }
            
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let nav = segue.destination as? UINavigationController
            let view = nav?.viewControllers.first as? UserEditProfileTableViewController
            view?.doctorName = self.username
        }
    }
    func segueWith(user: String) {
        username = user
        
        SaveEditClicked(self)
    }
    
    
    
    
    
    @IBAction func SaveEditClicked(_ sender: Any) {
        if self.userType == "doctor" {
            performSegue(withIdentifier: "edit", sender: sender)
        } else{
        
            performSegue(withIdentifier: "save", sender: sender)
            
            let docData: [String: Any] = [
                "isActive": self.isAvtive.isOn,
            ]
            
            self.db
                .collection("users")
                .document(self.username!)
                .setData(docData, merge: true)
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("user info successfully updated!")
                    }
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
