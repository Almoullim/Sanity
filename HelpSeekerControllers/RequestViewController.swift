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
        let docData: [String: Any] = [
            "created_at": Timestamp.init(),
            "helpSeekerName": self.name!,
            "helpSeekerUserName": self.currentUsername!,
            "issue": self.issueInput.text!,
            "description": self.descriptionInput.text!,
            "helpSeekerMobile": self.mobileInput.text!,
            "helperUserName": self.requestedUser!
        ]
        
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
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
