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
    
    // Google Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    @IBOutlet weak var UsersTable: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!
    
    var selectedUser: String?
    var userType: String?
    
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        loadUsers(userType: "all", searchText: nil)
        
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
        if let text = searchBar.text {
            users = []
            self.UsersTable.reloadData()
            
            loadUsers(userType: "all", searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        users = []
        self.UsersTable.reloadData()
        loadUsers(userType: "all", searchText: nil)
        
        searchBar.resignFirstResponder()
    }
    
    
    @IBAction func filterClicked(_ sender: UISegmentedControl) {
        users = []
        self.UsersTable.reloadData()
        
        if (sender.selectedSegmentIndex == 1) {
            print("help")
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
        return users.count
    }
    
    func loadUsers(userType: String, searchText: String?) {
        let collection = db.collection("users")
        var query: Query?
        
        if userType != "all" {
            query = collection.whereField("userType", isEqualTo: userType)
        }
        
        if searchText != nil {
            query = collection.order(by: "name").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
        }
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
        
        UsersTable.reloadData()
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        if segue.identifier == "UserProfile" {
            let nav = segue.destination as? UINavigationController
            let view = nav?.viewControllers.first as? UserProfileViewController
            view?.username = self.selectedUser
            print(self.selectedUser!)
            view?.userType = self.userType
        }
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
