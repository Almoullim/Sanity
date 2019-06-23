//
//  UsersListViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/15/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class UsersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UserCellDelegate  {
    
    // Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    // outlets
    @IBOutlet weak var UsersTable: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!
    
    // variables
    var selectedUser: String?
    var userType: String?
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // firebase api code
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        // load users
        loadUsers(userType: "all", searchText: nil)
        
        // dalegate
        SearchBar.delegate = self
        UsersTable.delegate = self
        UsersTable.dataSource = self
    }
    
    func segueWith(user: String) {
        selectedUser = user
        for user in users {
            if user.username == selectedUser {
                userType = user.userType
            }
        }
        requestedButtonClicked(self)
    }
    
    
    
    @IBAction func requestedButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "UserProfile", sender: nil)
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        // get search text and reload sessions
        if let text = searchBar.text {
            users = []
            self.UsersTable.reloadData()
            loadUsers(userType: "all", searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // discharge search and reload all sessions
        searchBar.text = nil
        users = []
        self.UsersTable.reloadData()
        loadUsers(userType: "all", searchText: nil)
        
        searchBar.resignFirstResponder()
    }
    
    
    @IBAction func filterClicked(_ sender: UISegmentedControl) {
        // clear users collection and reload users with fillter user type
        users = []
        self.UsersTable.reloadData()
        if (sender.selectedSegmentIndex == 1) {
            loadUsers(userType: "help-seeker", searchText: nil)
        } else if (sender.selectedSegmentIndex == 2) {
            loadUsers(userType: "volunteer", searchText: nil)
        } else if (sender.selectedSegmentIndex == 3) {
            loadUsers(userType: "doctor", searchText: nil)
        }else if (sender.selectedSegmentIndex == 0) {
            loadUsers(userType: "all", searchText: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // get users count and assign to rows count
        return users.count
    }
    
    func loadUsers(userType: String, searchText: String?) {
        // set collection [table]
        let collection = db.collection("users")
        var query: Query?
        
        if userType != "all" {
            // set a query to get users with single user type
            query = collection.whereField("userType", isEqualTo: userType)
        }
        
        if searchText != nil {
            // set search query
            query = collection.order(by: "name").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
        }
        
        // firebase api code to get documents
        if query == nil {
            collection.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.addUsers(querySnapshot!.documents)
                }
            }
            
        } else {
        query?.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.addUsers(querySnapshot!.documents)
            }
        }
        }
    }
    
    func addUsers(_ documents: [QueryDocumentSnapshot]) {
        // get each document data and add to users collection
        for document in documents {
            // Get the volunteer name of the document
            let username = document.data()["username"] as! String
            let name = document.data()["name"] as! String
            let userType = document.data()["userType"] as! String

            var daysSince: String = ""
            // Get the time stamp from the document
            if let timestamp = document.data()["created_at"] as? Timestamp {
                // Construct days since
                daysSince = timeSince(timestamp: timestamp)
            }
            let user = User(username: username, name: name, daysSince: daysSince)
            user?.userType = userType
            self.users.append(user!)
        }
        // reload table
        UsersTable.reloadData()
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // asign user info to cell
        let cell =  tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
        
        cell?.userFullName.text = self.users[indexPath.row].name
        cell?.userInfo.text = self.users[indexPath.row].getDaysSince
        cell?.username = self.users[indexPath.row].username
        cell?.delegate = self
        
        let storageRef = self.storage.reference()
        let imgRef = storageRef.child("images/" + self.users[indexPath.row].username + ".jpg")
        
        imgRef.downloadURL { (url, error) in
            guard let downloadURL = url else { return }
            cell?.userImage.downloaded(from: downloadURL)
        }
        
        return cell!
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // send info to next view
        if segue.identifier == "UserProfile" {
            if segue.destination is UserProfileViewController
            {
                let view = segue.destination as? UserProfileViewController
                view?.username = self.selectedUser
                view?.userType = self.userType
            }
        }
    }
    
    
    @IBAction func unwindToUsersList(segue:UIStoryboardSegue) {
        users = []
        self.UsersTable.reloadData()
        loadUsers(userType: "all", searchText: nil)
    }

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
