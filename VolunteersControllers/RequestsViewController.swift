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
    
    @IBOutlet weak var requestsTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedHelpSeeker: String?
    var username: String?
    
    var requests: [Request] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        loadRequests(requestedUser: "all", searchText: nil)
        
        searchBar.delegate = self
        requestsTable.delegate = self
        requestsTable.dataSource = self
        
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("uid", isEqualTo: currentUser.uid)
                .getDocuments() { (querySnapshot, err) in
                    if let data = querySnapshot?.documents[0].data() {
                        self.username = data["username"] as? String
                    }
            }
        }
    }
    
    func segueWith(user: String) {
        selectedHelpSeeker = user
    }
    
    func call(_ mobile: String) {
        print(mobile)
        let api = "https://us-central1-poly-mp-project.cloudfunctions.net";
        
        if let incEndPoint = URL(string: (api + "/userFieldInc?user=" + username!)) {
            URLSession.shared.dataTask(with: incEndPoint).resume()
        }
        
        if let number = URL(string: "tel://" + mobile.replacingOccurrences(of: " ", with: "")) {
            UIApplication.shared.open(number, options: [:]) { (success:Bool) in
                self.db
                    .collection("requests")
                    .document(self.selectedHelpSeeker!)
                    .delete()
            }
        }
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        if let text = searchBar.text {
            requests = []
            self.requestsTable.reloadData()
            
            loadRequests(requestedUser: "all", searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        requests = []
        self.requestsTable.reloadData()
        loadRequests(requestedUser: "all", searchText: nil)
        
        searchBar.resignFirstResponder()
    }
    
    @IBAction func filterClicked(_ sender: UISegmentedControl) {
        requests = []
        self.requestsTable.reloadData()
        
        if (sender.selectedSegmentIndex == 1) {
            loadRequests(requestedUser: "me", searchText: nil)
        } else if (sender.selectedSegmentIndex == 0) {
            loadRequests(requestedUser: "all", searchText: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func loadRequests(requestedUser: String, searchText: String?) {
        let collection = db.collection("requests")
        var query: Query? = nil
        
        if requestedUser != "all" {
            query = collection.whereField("helperUserName", isEqualTo: username!)
        }
        
        if searchText != nil {
            if query == nil {
                query = collection.order(by: "helpSeekerName").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
            } else {
                query = query?.order(by: "helpSeekerName").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
            }
        }
        
        if query != nil {
            query?.getDocuments(completion: handleDocuments)
        } else {
            collection.getDocuments(completion: handleDocuments)
        }
    }
    
    func handleDocuments(querySnapshot: QuerySnapshot?, err: Error?) {
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            self.addHelpSeekers(querySnapshot!.documents)
        }
    }
    
    func addHelpSeekers(_ documents: [QueryDocumentSnapshot]) {
        for document in documents {
            let name = document.data()["helpSeekerName"] as! String
            let username = document.data()["helpSeekerUserName"] as! String
            let mobile = document.data()["helpSeekerMobile"] as! String
            var daysSince: String = ""
            // Get the time stamp from the document
            if let timestamp = document.data()["created_at"] as? Timestamp {
                // Construct days since
                daysSince = timeSince(timestamp: timestamp) + " " + NSLocalizedString("ago", comment: "")
            }
            
            let request = Request(helpSeekerUserName: username, helpSeekerName: name, helpSeekerMobile: mobile, createdAt: daysSince)
            
            self.requests.append(request!)
        }
        
        requestsTable.reloadData()
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "VolunteerCell") as? UserCell

        cell?.userFullName.text = self.requests[indexPath.row].helpSeekerName
        cell?.userInfo.text = self.requests[indexPath.row].getDaysSince
        cell?.username = self.requests[indexPath.row].helpSeekerUserName
        cell?.mobile = self.requests[indexPath.row].helpSeekerMobile
        cell?.delegate = self
        
        let storageRef = self.storage.reference()
        let imgRef = storageRef.child("images/" + self.requests[indexPath.row].helpSeekerUserName + ".jpg")
        
        imgRef.downloadURL { (url, error) in
            guard let downloadURL = url else { return }
            cell?.userImage.downloaded(from: downloadURL)
        }
        
        return cell!
    }
    
}
