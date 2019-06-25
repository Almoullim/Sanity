//
//  VolunteersViewController.swift
//  Sanity
//
//  Created by Ali on 3/31/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AppointmentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UserCellDelegate {
    
    // Google Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    @IBOutlet weak var appointmentsTable: UITableView!
    private var refreshControl: UIRefreshControl?
    
    var selectedAppointmentID: String?
    
    var appointments: [Appointment] = []
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        appointmentsTable.delegate = self
        appointmentsTable.dataSource = self

        self.refreshControl = UIRefreshControl()
        appointmentsTable.refreshControl = self.refreshControl
        refreshControl!.addTarget(self, action: #selector(loadAppointments), for: .valueChanged)
        
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("uid", isEqualTo: currentUser.uid)
                .getDocuments() { (querySnapshot, err) in
                    if let data = querySnapshot?.documents[0].data() {
                        self.username = data["username"] as? String
                        self.loadAppointments()
                    }
            }
        }
    }
    
    func segueWith(user: String) {
        selectedAppointmentID = user
    }
    
    func call(_ mobile: String) {
        if let number = URL(string: "tel://" + mobile.replacingOccurrences(of: " ", with: "")) {
            UIApplication.shared.open(number, options: [:]) { (success:Bool) in
                self.db
                    .collection("appointments")
                    .document(self.selectedAppointmentID!)
                    .delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            self.loadAppointments()
                        }
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments.count
    }
    
    @objc func loadAppointments() {
        appointments = []
        self.appointmentsTable.reloadData()
        
        let query = db.collection("appointments").whereField("doctorName", isEqualTo: username!)
        
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.addVolunteers(querySnapshot!.documents)
                self.refreshControl!.endRefreshing()
            }
        }
    }
    
    func addVolunteers(_ documents: [QueryDocumentSnapshot]) {
        for document in documents {
            let id = document.documentID
            let name = document.data()["helpSeekerName"] as! String
            let username = document.data()["helpSeekerUserName"] as! String
            let mobile = document.data()["helpSeekerMobile"] as! String
            
            var daysSince: String = ""
            // Get the time stamp from the document
            if let timestamp = document.data()["created_at"] as? Timestamp {
                // Construct days since
                daysSince = timeSince(timestamp: timestamp)
            }
            
            let appointment = Appointment(appointmentID: id, helpSeekerUserName: username, helpSeekerName: name, helpSeekerMobile: mobile, helperUserName: username, createdAt: daysSince)
            
            self.appointments.append(appointment!)
        }
        
        appointmentsTable.reloadData()
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "VolunteerCell") as? UserCell
        
        cell?.userFullName.text = self.appointments[indexPath.row].helpSeekerName
        cell?.userInfo.text = self.appointments[indexPath.row].getDaysSince
        cell?.username = self.appointments[indexPath.row].helpSeekerUserName
        cell?.delegate = self
        cell?.mobile = self.appointments[indexPath.row].helpSeekerMobile
        
        let storageRef = self.storage.reference()
        let imgRef = storageRef.child("images/" + self.appointments[indexPath.row].helpSeekerUserName + ".jpg")
        
        imgRef.downloadURL { (url, error) in
            guard let downloadURL = url else { return }
            cell?.userImage.downloaded(from: downloadURL)
        }
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Request" {
            let nav = segue.destination as? UINavigationController
            let view = nav?.viewControllers.first as? RequestViewController
            view?.requestedUser = self.selectedAppointmentID
            view?.requestType = "volunteer"
        }
    }
}
