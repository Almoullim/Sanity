//
//  DoctorsViewController.swift
//  Sanity
//
//  Created by Ali on 5/26/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class DoctorsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // Google Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    @IBOutlet weak var DoctorsTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var doctors: [Doctor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        loadDcotors(gender: "all", searchText: nil)
        
        searchBar.delegate = self
        DoctorsTable.delegate = self
        DoctorsTable.dataSource = self
    }
    
    @IBAction func requestButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "Request", sender: nil)
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        if let text = searchBar.text {
            doctors = []
            self.DoctorsTable.reloadData()
            
            loadDcotors(gender: "all", searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        doctors = []
        self.DoctorsTable.reloadData()
        loadDcotors(gender: "all", searchText: nil)
        
        searchBar.resignFirstResponder()
    }
    
    @IBAction func filterClicked(_ sender: UISegmentedControl) {
        doctors = []
        self.DoctorsTable.reloadData()
        
        if (sender.selectedSegmentIndex == 1) {
            loadDcotors(gender: "m", searchText: nil)
        } else if (sender.selectedSegmentIndex == 2) {
            loadDcotors(gender: "f", searchText: nil)
        } else if (sender.selectedSegmentIndex == 0) {
            loadDcotors(gender: "all", searchText: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctors.count
    }
    
    func loadDcotors(gender: String, searchText: String?) {
        var query = db.collection("users").whereField("userType", isEqualTo: "doctor")
        
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
                self.addDoctors(querySnapshot!.documents)
            }
        }
    }
    
    func addDoctors(_ documents: [QueryDocumentSnapshot]) {
        for document in documents {
            // Get the volunteer name of the document
            let username = document.data()["username"] as! String
            let name = document.data()["name"] as! String
            
            var daysSince: String = ""
            // Get the time stamp from the document
            if let timestamp = document.data()["created_at"] as? Timestamp {
                // Construct days since
                daysSince = timeSince(timestamp: timestamp)
            }
            
            self.doctors.append(Doctor(username: username, name: name, daysSince: daysSince)!)
        }
        
        DoctorsTable.reloadData()
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "DoctorCell") as? UserCell
        
        cell?.userFullName.text = self.doctors[indexPath.row].name
        cell?.userInfo.text = self.doctors[indexPath.row].getDaysSince
        
        let storageRef = self.storage.reference()
        let imgRef = storageRef.child("images/" + self.doctors[indexPath.row].username + ".jpg")
        
        imgRef.downloadURL { (url, error) in
            guard let downloadURL = url else { return }
            cell?.userImage.downloaded(from: downloadURL)
        }
        
        return cell!
    }
}
