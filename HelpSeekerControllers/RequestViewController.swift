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
            "helpSeekerName": self.name!,
            "helpSeekerUserName": self.currentUsername!,
            "issue": self.issueInput.text!,
            "description": self.descriptionInput.text!,
            "created_at": Timestamp.init(),
            "helpSeekerMobile": mobileInput.text!
        ]
        var collectionName: String = ""

        if self.requestType == "volunteer" {
            collectionName = "requests"
        } else if self.requestType == "doctor" {
            collectionName = "appointments"
        }
        
        if let requestedUser = self.requestedUser {
            docData["helperUserName"] = requestedUser
        }
        
        self.db
            .collection(collectionName)
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
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
