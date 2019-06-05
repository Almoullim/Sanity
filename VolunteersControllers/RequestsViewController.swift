//
//  RequestsViewController.swift
//  Sanity
//
//  Created by Ali on 6/5/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class RequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UserCellDelegate {

    
    // Google Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    @IBOutlet weak var HelpSeekersTable: UITableView!
//    @IBOutlet weak var VolunteersTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedHelpSeeker: String?
    var username: String?
    
    var HelpSeekers: [HelpSeeker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        loadHelpSeekers(requestedUser: "all", searchText: nil)
        
        searchBar.delegate = self
        HelpSeekersTable.delegate = self
        HelpSeekersTable.dataSource = self
        
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("uid", isEqualTo: currentUser.uid)
                .getDocuments() { (querySnapshot, err) in
                    if let data = querySnapshot?.documents[0].data() {
                        self.username = data["username"] as? String
                    }
            }
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
    
    func segueWith(user: String) {
        selectedHelpSeeker = user
        print(user)
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        if let text = searchBar.text {
            HelpSeekers = []
            self.HelpSeekersTable.reloadData()
            
            loadHelpSeekers(requestedUser: "all", searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        HelpSeekers = []
        self.HelpSeekersTable.reloadData()
        loadHelpSeekers(requestedUser: "all", searchText: nil)
        
        searchBar.resignFirstResponder()
    }
    
    @IBAction func filterClicked(_ sender: UISegmentedControl) {
        HelpSeekers = []
        self.HelpSeekersTable.reloadData()
        
        if (sender.selectedSegmentIndex == 1) {
            loadHelpSeekers(requestedUser: "me", searchText: nil)
        } else if (sender.selectedSegmentIndex == 0) {
            loadHelpSeekers(requestedUser: "all", searchText: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HelpSeekers.count
    }
    
    func loadHelpSeekers(requestedUser: String, searchText: String?) {
        var query = db.collection("requests").whereField("requestType", isEqualTo: "volunteer")
        
        if requestedUser != "all" {
            query = query.whereField("requestedUser", isEqualTo: username!)
        }
        
        if searchText != nil {
            query = query.order(by: "name").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
        }
        
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.addHelpSeekers(querySnapshot!.documents)
            }
        }
    }
    
    func addHelpSeekers(_ documents: [QueryDocumentSnapshot]) {
        for document in documents {
            let name = document.data()["name"] as! String
            let username = document.data()["username"] as! String
            var daysSince: String = ""
            // Get the time stamp from the document
            if let timestamp = document.data()["created_at"] as? Timestamp {
                // Construct days since
                daysSince = timeSince(timestamp: timestamp) + " ago"
            }
            
            self.HelpSeekers.append(HelpSeeker(username: username, name: name, daysSince: daysSince)!)
        }
        
        HelpSeekersTable.reloadData()
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "VolunteerCell") as? UserCell
        
        cell?.userFullName.text = self.HelpSeekers[indexPath.row].name
        cell?.userInfo.text = self.HelpSeekers[indexPath.row].getDaysSince
        cell?.username = self.HelpSeekers[indexPath.row].username
        cell?.delegate = self
        
        let storageRef = self.storage.reference()
        let imgRef = storageRef.child("images/" + self.HelpSeekers[indexPath.row].username + ".jpg")
        
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
            view?.requestedUser = self.selectedHelpSeeker
            view?.requestType = "volunteer"
        }
    }
    
}
