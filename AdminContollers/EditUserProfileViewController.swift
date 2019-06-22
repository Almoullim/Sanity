//
//  EditUserProfileViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/22/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class EditUserProfileViewController: UITableViewController {

    // outlets
    @IBOutlet weak var userImage: DesignableUIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var isActive: UISwitch!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
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
        if let currentUser = username {
            navigationItem.title = currentUser
            db.collection("users").whereField("username", isEqualTo: currentUser)
                .getDocuments() { (querySnapshot, err) in
                    
                    if let data = querySnapshot?.documents[0].data() {
                        self.userName.text = data["name"] as? String
                        self.isActive.isOn = (data["isActive"] as? Bool)!
                        self.address.text = data["address"] as? String
                        
                        
                        
                        let storageRef = self.storage.reference()
                        let imgRef = storageRef.child("images/" + currentUser + ".jpg")
                        imgRef.downloadURL { (url, error) in
                            guard let downloadURL = url else { return }
                            print("image download started")
                            URLSession.shared.dataTask(with: downloadURL) { data, response, error in
                                let image = UIImage(data: data!)
                                DispatchQueue.main.async() {
                                    print("image download finished")
                                    self.userImage.image = image
                                }
                                }.resume()
                        }
                    }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
        return 2
        case 1:
            if self.userType == "doctor" {
                return 2
            }else{
                return 1
            }
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // assign cell article to variable
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [2, 0]:
            if let id = self.username {
                db.collection("users").document(id).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("User successfully removed!")
                    }
                }
                performSegue(withIdentifier: "userList", sender: nil)
            }
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userProfile" {
            if segue.destination is UserProfileViewController
            {
                let view = segue.destination as? UserProfileViewController
                view?.username = self.username
                view?.userType = self.userType
            }
                // get data from outlets and edit information in database
                let docData: [String: Any]
                if userType == "doctor" {
                docData = [
                    "isActive": self.isActive.isOn,
                    "address": self.address.text!
                ]
                }else{
                docData = [
                    "isActive": self.isActive.isOn
                ]
                }
                    self.db
                        .collection("users")
                        .document(username!)
                        .setData(docData, merge: true)
                        { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("User updated!")
                            }
                    }
            }
        }

}
