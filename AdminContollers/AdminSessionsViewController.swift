//
//  SessionsViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/15/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AdminSessionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UserCellDelegate {
    
    
    
    @IBOutlet weak var SessionsTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var sessionID: String?
    
    // Google Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    var sessions: [Session] = []
    
    override func viewDidLoad() {
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        searchBar.delegate = self
        SessionsTable.delegate = self
        SessionsTable.dataSource = self
        loadSessions(searchText: nil)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        if let text = searchBar.text {
            sessions = []
            self.SessionsTable.reloadData()
            
            loadSessions(searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        sessions = []
        self.SessionsTable.reloadData()
        loadSessions(searchText: nil)

        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func loadSessions(searchText: String?) {
        let collection = db.collection("sessions")
        var query: Query?
        
        if searchText != nil {
            query = collection.order(by: "name").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
        }
        
        if query == nil {
            collection.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.addSession(querySnapshot!.documents)
                }
            }
            
        } else {
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
        for document in documents {
            let helpSeekername = document.data()["helpSeekerUserName"] as! String
            let helperName = document.data()["helperUserName"] as! String
            print(helperName)
            sessionID = (document.documentID )
            print(sessionID!)
            var daysSince = ""
            if let timestamp = document.data()["daysSince"] as? Timestamp {
                // Construct days since
                daysSince = timeSince(timestamp: timestamp)
            }
            
            
            self.sessions.append(Session(sessionID: sessionID!, helpSeekerUserName: helpSeekername, helperUserName: helperName, daysSince: daysSince)!)
            print(sessions.count)
        }
        
        SessionsTable.reloadData()
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "SessionCell") as? SessionRecoredTableViewCell

        cell?.usersName.text = "\(self.sessions[indexPath.row].helpSeekerUserName) & \(self.sessions[indexPath.row].helperUserName)"
        cell?.timeSince.text = self.sessions[indexPath.row].getDaysSince
        cell?.delegate = self

        
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
    
    @IBAction func showSession(_ sender: Any) {
        print("next")
        performSegue(withIdentifier: "showSession", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("\(self.sessionID!) session")

        if segue.identifier == "showSession" {
            print("\(self.sessionID!) session1")
            if segue.destination is AdminSessionViewController
            {

                let view = segue.destination as? AdminSessionViewController
                view?.sessionID = self.sessionID
                print("\(self.sessionID!) session2")
            }
        }
    }

}
