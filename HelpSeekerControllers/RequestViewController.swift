//
//  RequestViewController.swift
//  Sanity
//
//  Created by Ali on 6/5/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class RequestViewController: UITableViewController {

    @IBOutlet weak var mobileInput: UITextField!
    @IBOutlet weak var issueInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextView!
    
    var requestedUser: String?
    var requestType: String?
    var currentUsername: String?
    var requests: Int?
    var name: String?
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("uid", isEqualTo: currentUser.uid)
                .getDocuments() { (querySnapshot, err) in
                    
                    if let data = querySnapshot?.documents[0].data() {
                        if let mobile = data["mobile"] as? String {
                            self.mobileInput.text = mobile
                        }
                        
                        if let issue = data["issue"] as? String {
                            self.issueInput.text = issue
                        }
                        if let requestsCount = data["requestsCount"] as? Int {
                            self.requests = requestsCount
                        } else {
                            self.requests = 0
                        }
                        
                        self.currentUsername = data["username"] as? String
                        self.name =  data["name"] as? String
                    }
            }
            
        }
    }

    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveClicked(_ sender: Any) {

        var docData: [String: Any] = [
            "created_at": Timestamp.init(),
            "helpSeekerName": self.name!,
            "helpSeekerUserName": self.currentUsername!,
            "issue": self.issueInput.text!,
            "description": self.descriptionInput.text!,
            "helpSeekerMobile": self.mobileInput.text!
        ]
        
        if let helper = self.requestedUser {
            docData["helperUserName"] = helper
        }
        
        self.db
            .collection("requests")
            .document(self.currentUsername!)
            .setData(docData)
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("request created/updated!")
                    self.dismiss(animated: true, completion: nil)
                }
        }
        
        let userData: [String: Any] = [
            "requestsCount": (requests! + 1)
        ]
        
        self.db
            .collection("users")
            .document(self.currentUsername!)
            .setData(userData, merge: true)
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("requestsCount increased!")
                    self.dismiss(animated: true, completion: nil)
                }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
