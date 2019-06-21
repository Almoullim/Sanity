//
//  AdminAppointmentsViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/19/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AdminAppointmentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UserCellDelegate {

    
    // outlet
    @IBOutlet weak var appointmentTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // pass info
    var appointmentID: String?
    
    // Google Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    var appointments: [Appointment] = []
    
    override func viewDidLoad() {
        
        // firebase api code
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        loadAppointment(searchText: nil)
        
        searchBar.delegate = self
        appointmentTable.delegate = self
        appointmentTable.dataSource = self
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        // get search text and reload sessions
        if let text = searchBar.text {
            appointments = []
            self.appointmentTable.reloadData()
            loadAppointment(searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // discharge search and reload all sessions
        searchBar.text = nil
        appointments = []
        self.appointmentTable.reloadData()
        loadAppointment(searchText: nil)
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // get appointments coun and assign to rows count
        return appointments.count
    }
    
    func loadAppointment(searchText: String?) {
        // set collection [table]
        let collection = db.collection("appointments")
        var query: Query?
        if searchText != nil {
            // set search query
            query = collection.order(by: "name").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
        }
        
        // get documents
        if query == nil {
            collection.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.addAppointment(querySnapshot!.documents)
                }
            }
            
        } else {
            query?.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.addAppointment(querySnapshot!.documents)
                }
            }
        }
    }
    
    func addAppointment(_ documents: [QueryDocumentSnapshot]) {
        // get each document info and assign to new appointment object
        for document in documents {
            let appointmentID = document.documentID
            let helpSeekername = document.data()["helpSeekerName"] as! String
            let helperName = document.data()["doctorName"] as! String
            let createAt = document.data()["createAt"] as! Timestamp
            let date = document.data()["appointmentDate"] as! Timestamp
            let createAtString = timeSince(timestamp: createAt)
            let dateString = timeSince(timestamp: date)

            // add new appointment object to collection
            self.appointments.append(Appointment(appointmentID: appointmentID, helpSeekerUserName: helpSeekername, helperUserName: helperName, date: dateString, time: dateString, createAt: createAtString)!)
        }
        // reload table
        appointmentTable.reloadData()
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get appointment info to cell
        let cell =  tableView.dequeueReusableCell(withIdentifier: "appimtmentCell") as? SessionRecoredTableViewCell
        cell?.usersName.text = "\(self.appointments[indexPath.row].helpSeekerUserName) & \(self.appointments[indexPath.row].helperUserName)"
        
        cell?.timeSince.text = self.appointments[indexPath.row].getDaysSince
        
        
        let storageRef = self.storage.reference()
        let imgRef = storageRef.child("images/" + self.appointments[indexPath.row].helpSeekerUserName + ".jpg")
        let imgRef1 = storageRef.child("images/" + self.appointments[indexPath.row].helperUserName + ".jpg")
        
        imgRef.downloadURL { (url, error) in
            guard let downloadURL = url else { return }
            cell?.userOneImage.downloaded(from: downloadURL)
        }
        imgRef1.downloadURL { (url, error) in
            guard let downloadURL = url else { return }
            cell?.userTwoImage.downloaded(from: downloadURL)
        }
        return cell!
    }
    
    @IBAction func showSession(_ sender: Any) {
        
        performSegue(withIdentifier: "showAppointment", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass info to next view
        if segue.identifier == "showAppointment" {
            if segue.destination is AdminAppointmentViewController
            {
                let view = segue.destination as? AdminAppointmentViewController
                view?.appointmentID = self.appointmentID
            }
        }
    }


}
