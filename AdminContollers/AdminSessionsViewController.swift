//
//  SessionsViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/15/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AdminSessionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SessionRecoredCellDelegate {
    
    
    // outlets
    @IBOutlet weak var SessionsTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    // pass info
    var sessionID: String?
    
    // firebase connection
    var db: Firestore!
    var storage: Storage!
    
    
    var sessions: [Session] = []

    override func viewDidLoad() {
        
        // Firebase api code
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        // dalegate
        searchBar.delegate = self
        SessionsTable.delegate = self
        SessionsTable.dataSource = self
        // load all sessions
        loadSessions(searchText: nil)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        // get search text and reload sessions
        if let text = searchBar.text {
            sessions = []
            self.SessionsTable.reloadData()
            loadSessions(searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // discharge search and reload all sessions
        searchBar.text = nil
        sessions = []
        self.SessionsTable.reloadData()
        loadSessions(searchText: nil)
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // get sessions count and assign to row count
        return sessions.count
    }
    
    func loadSessions(searchText: String?) {
        // set collection [table]
        let collection = db.collection("sessions")
        var query: Query?
        
        if searchText != nil {
            // set search query
            query = collection.order(by: "name").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
        }
        
        if query == nil {
            // get all documents
            collection.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.addSession(querySnapshot!.documents)
                }
            }
            
        } else {
            // get documents with search text
            query?.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.addSession(querySnapshot!.documents)
                }
            }
        }
    }
    
    func addSession(_ documents: [QueryDocumentSnapshot]) {
        // get collection [table] documents and assign each document info to a new session
        for document in documents {
            let helpSeekername = document.data()["helpSeekerUserName"] as! String
            let helperName = document.data()["helperUserName"] as! String
            let sessionID = (document.documentID )
            var daysSince = ""
            if let timestamp = document.data()["daysSince"] as? Timestamp {
                // Construct days since
                daysSince = timeSince(timestamp: timestamp)
            }
            // add session to the sessions collection
            self.sessions.append(Session(sessionID: sessionID, helpSeekerUserName: helpSeekername, helperUserName: helperName, daysSince: daysSince)!)
        }
        // reload table with new data
        SessionsTable.reloadData()
    }
    
    func getUserName(userName: String, completion: @escaping (String) -> Void) {
        
        // get user full name using function with closure
        // code reference
        // https://stackoverflow.com/questions/54988558/how-to-return-expected-value-from-within-another-function-in-swift
        let docRef = db.collection("users").document(userName)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion("")

            } else {
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    if let data = document.data() {
                        completion((data["name"] as? String)!)
                    }
                    
                }
            }
        }
    }
    
    func getUserNames(Helper helperPar: String, HelpSeeker helpSeekerPar:String, completion: @escaping (String) -> Void)  {
        // get helpseeker and helper full names using function with closure
        // code reference
        // https://stackoverflow.com/questions/54988558/how-to-return-expected-value-from-within-another-function-in-swift
        var helperUserName:String = ""
        var helpSeekerUserName:String = ""
        // get helprer user name
        self.getUserName(userName: helperPar) { helper in
            helperUserName = helper
            self.getUserName(userName: helpSeekerPar) { helpSeeker in
                // get help seeker user name
                helpSeekerUserName = helpSeeker
                // send both users full name back
                completion("\(helpSeekerUserName) & \(helperUserName)")
            }
        }
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "SessionCell") as? SessionRecoredTableViewCell
        
        // assign session data to cells
        self.getUserName(userName: self.sessions[indexPath.row].helperUserName) { volunteer in
            // get volunteer user name

            self.getUserName(userName: self.sessions[indexPath.row].helpSeekerUserName) { helpSeeker in
                // get help seeker user name
                // send both users full name back
                cell?.usersName.text = "\(helpSeeker) & \(volunteer)"
            }
        }
        
        cell?.timeSince.text = self.sessions[indexPath.row].getDaysSince
        cell?.delegate = self
        cell?.ID = self.sessions[indexPath.row].sessionID
        let storageRef = self.storage.reference()
        let imgRef = storageRef.child("images/" + self.sessions[indexPath.row].helpSeekerUserName + ".jpg")
        let imgRef1 = storageRef.child("images/" + self.sessions[indexPath.row].helperUserName + ".jpg")
        
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
    
     internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.sessionID = self.sessions[indexPath.row].sessionID
        
    }
    
    func segueWith(ID: String) {
        sessionID = ID
        showSession(self)
    }
    @IBAction func showSession(_ sender: Any) {
        
        performSegue(withIdentifier: "showSession", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass session id to the next view
        if segue.identifier == "showSession" {
            if segue.destination is AdminSessionViewController
            {

                let view = segue.destination as? AdminSessionViewController
                view?.sessionID = self.sessionID
            }
        }
    }

}
