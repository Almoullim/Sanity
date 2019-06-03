//
//  EditProfileViewController.swift
//  Sanity
//
//  Created by Ali on 5/28/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UITableViewController {

    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    var datePickerIsHidden = true
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // inputs
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var dateOfBirth: UILabel!
    @IBOutlet weak var issueInput: UITextField!
    @IBOutlet weak var languageInput: UITextField!
    @IBOutlet weak var locationInput: UITextField!
    
    var username: String?
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
                        self.username = data["username"] as? String
                        self.nameInput.text = data["name"] as? String
                        
                        if let timestamp = data["dob"] as? Timestamp {
                            // Construct days since
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd/MM/yyyy"
                            
                            self.dateOfBirth.text = dateFormatter.string(from: timestamp.dateValue())
                            self.datePicker.date = timestamp.dateValue()
                            
                            self.dateOfBirth.textColor = .black
                        }
                        
                        self.issueInput.text = data["issue"] as? String
                        self.languageInput.text = data["language"] as? String
                        self.locationInput.text = data["location"] as? String
                    }
            }
            
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        var dob: Timestamp? = nil
        
        if  let dateString = self.dateOfBirth.text,
            let date = dateFormatter.date(from: dateString) {
            dob = Timestamp(date: date)
        }
        
        let docData: [String: Any] = [
            "name": self.nameInput.text!,
            "issue":self.issueInput.text!,
            "language": self.languageInput.text!,
            "location": self.locationInput.text!,
            "dob": dob ?? NSNull(),
        ]
        
        self.db
            .collection("users")
            .document(self.username!)
            .setData(docData, merge: true)
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated!")
                    self.dismiss(animated: true, completion: nil)
                }
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func datePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateOfBirth.text = dateFormatter.string(from: datePicker.date)
        self.dateOfBirth.textColor = .black
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case [1, 1]:
            return datePickerIsHidden ? 0.0 : 216.0
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [1, 0]:
            tableView.beginUpdates()
            datePickerIsHidden = !datePickerIsHidden
            tableView.endUpdates()
        default:
            print("Wrong selection")
        }
    }
    
    
}
