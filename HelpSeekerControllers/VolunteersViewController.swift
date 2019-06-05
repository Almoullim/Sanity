//
//  VolunteersViewController.swift
//  Sanity
//
//  Created by Ali on 3/31/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class VolunteersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UserCellDelegate {
    
    // Google Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    @IBOutlet weak var VolunteersTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedVolunteer: String?
    
    var volunteers: [Volunteer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        loadVolunteers(gender: "all", searchText: nil)
        
        searchBar.delegate = self
        VolunteersTable.delegate = self
        VolunteersTable.dataSource = self
    }
    
    func segueWith(user: String) {
        selectedVolunteer = user
        requestButtonClicked(self)
    }
    
    @IBAction func requestButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "Request", sender: nil)
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
    
    func loadVolunteers(gender: String, searchText: String?) {
        var query = db.collection("users").whereField("userType", isEqualTo: "volunteer")
        
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
        for document in documents {
            // Get the volunteer name of the document
            let name = document.data()["name"] as! String
            let username = document.data()["username"] as! String
            
            var daysSince: String = ""
            // Get the time stamp from the document
            if let timestamp = document.data()["created_at"] as? Timestamp {
                // Construct days since
                daysSince = timeSince(timestamp: timestamp)
            }
            
            self.volunteers.append(Volunteer(username: username, name: name, daysSince: daysSince)!)
        }
        
        VolunteersTable.reloadData()
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "VolunteerCell") as? UserCell
    
        cell?.userFullName.text = self.volunteers[indexPath.row].name
        cell?.userInfo.text = self.volunteers[indexPath.row].getDaysSince
        cell?.username = self.volunteers[indexPath.row].username
        cell?.delegate = self
        
        let storageRef = self.storage.reference()
        let imgRef = storageRef.child("images/" + self.volunteers[indexPath.row].username + ".jpg")
        
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
            view?.requestedUser = self.selectedVolunteer
            view?.requestType = "volunteer"
        }
    }
}
