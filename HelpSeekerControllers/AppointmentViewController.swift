//
//  AppointmentViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/23/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AppointmentViewController: UITableViewController {

    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    var datePickerIsHidden = true
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var mobileInput: UITextField!
    @IBOutlet weak var issueInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextView!
    @IBOutlet weak var dateInput: UILabel!
    
    var requestedDoctor: String?
    var currentUsername: String?
    var currentUserFullname: String?
    var appointmentDate: Timestamp?
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                        self.currentUserFullname = data["name"] as? String
                    }
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [0, 1]:
            tableView.beginUpdates()
            datePickerIsHidden = !datePickerIsHidden
            tableView.endUpdates()
        default:
            print("Wrong selection")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doctorsList" {
            let docData: [String: Any] = [
                "appointmentDate": self.appointmentDate!,
                "created_at": Timestamp.init(),
                "helpSeekerUserName": self.currentUsername!,
                "helpSeekerName": self.currentUserFullname!,
                "issue": self.issueInput.text!,
                "description": self.descriptionInput.text!,
                "helpSeekerMobile": self.mobileInput.text!,
                "doctorName": self.requestedDoctor!,
                "isApproved": false,
                "isCompleted": false
            ]
            
            
            self.db
                .collection("appointments")
                .document()
                .setData(docData)
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Appointment Added!")
                        self.dismiss(animated: true, completion: nil)
                    }
            }
        }
    }
    @IBAction func saveClicked(_ sender: Any) {
        performSegue(withIdentifier: "doctorsList", sender: nil)
    }

    @IBAction func datePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        self.appointmentDate = Timestamp(date: datePicker.date)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateInput.text = dateFormatter.string(from: datePicker.date)
        self.dateInput.textColor = .black
    }
    


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case [0, 2]:
            return datePickerIsHidden ? 0.0 : 216.0
        case [0,4]:
            return 200
        default:
            return 44.0
        }
    }
}
