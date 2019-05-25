//
//  VolunteersViewController.swift
//  Sanity
//
//  Created by Ali on 3/31/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

struct Volunteer {
    var name: String
    var daysSince: String
    var getDaysSince: String {
        get {
            return "Member since " + self.daysSince
        }
    }
}

class VolunteersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // Google Firestore connection
    var db: Firestore!
    
    @IBOutlet weak var VolunteersTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var volunteers: [Volunteer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        loadVolunteers(gender: "all", searchText: nil)
        
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        if let text = searchBar.text {
            volunteers = []
            self.VolunteersTable.reloadData()
            
            loadVolunteers(gender: "all", searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        volunteers = []
        self.VolunteersTable.reloadData()
        loadVolunteers(gender: "all", searchText: nil)
        
        searchBar.resignFirstResponder()
    }
    
    @IBAction func filterClicked(_ sender: UISegmentedControl) {
        volunteers = []
        self.VolunteersTable.reloadData()
    
        if (sender.selectedSegmentIndex == 1) {
            loadVolunteers(gender: "m", searchText: nil)
        } else if (sender.selectedSegmentIndex == 2) {
            loadVolunteers(gender: "f", searchText: nil)
        } else if (sender.selectedSegmentIndex == 0) {
            loadVolunteers(gender: "all", searchText: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteers.count
    }
    
//    func loadAllVolunteers() {
//        db.collection("users").whereField("userType", isEqualTo: "volunteer")
//            .getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    self.addVolunteers(querySnapshot!.documents)
//                }
//        }
//    }
//
//    func loadGenderSpecificVolunteers(_ gender: String) {
//        db.collection("users").whereField("userType", isEqualTo: "volunteer")
//            .whereField("gender", isEqualTo: gender).getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    self.addVolunteers(querySnapshot!.documents)
//                }
//        }
//    }
    
    func loadVolunteers(gender: String) {
        var query = db.collection("users").whereField("userType", isEqualTo: "volunteer")
            query = query.whereField("userType", isEqualTo: "volunteer")
        
        if gender != "all" {
            query = query.whereField("gender", isEqualTo: gender)
        }
        
        if searchText != nil {
            query = query.order(by: "name").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
        }

        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.addVolunteers(querySnapshot!.documents)
            }
        }
    }
    
    func addVolunteers(_ documents: [QueryDocumentSnapshot]) {
        self.VolunteersTable.beginUpdates()
        var counter = 0
        
        for document in documents {
            // Get the volunteer name of the document
            let name = document.data()["name"] as! String
            
            // Get the time stamp from the document
            let date = document.data()["created_at"]! as! Timestamp
            // Construct days since
            let secondsSince = Int64(Date().timeIntervalSince1970) - date.seconds
            let daysSince = String((secondsSince / 86400)) + " days"
            
            self.volunteers.append(Volunteer(name: name, daysSince: daysSince))
            
            self.VolunteersTable.insertRows(at: [IndexPath(row: counter, section: 0)], with: .automatic)
            
            counter += 1
        }
        
        self.VolunteersTable.endUpdates()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "VolunteerCell") as? VolunteerCell
    
        cell?.volunteerName.text = volunteers[indexPath.row].name
        cell?.volunteerInfo.text = volunteers[indexPath.row].getDaysSince
        cell?.volunteerImage.image = UIImage(named: "women")
        
        return cell!
    }
}
