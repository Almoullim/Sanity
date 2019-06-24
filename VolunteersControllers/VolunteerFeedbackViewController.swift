//
//  FeedbackViewController.swift
//  Sanity
//
//  Created by Ali on 6/24/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class VolunteerFeedbackViewController: UITableViewController {

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var feedbackMessage: UITextView!
    @IBOutlet weak var ratingSlider: UISlider!
    
     var db: Firestore!
    
    var started: Int?
    var username: String?
    var helpSeekerUsername: String?
    var sessionId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.hideKeyboardWhenTappedAround()
        
        db.collection("users").whereField("username", isEqualTo: self.username!).getDocuments() { querySnapshot, err in
            self.name.text = querySnapshot?.documents[0].data()["name"] as? String
        }
    }
    
    @IBAction func saveFeedback(_ sender: Any) {
        let duration = (Date().inMilliseconds - started!) / 1000
        
        let data: [String: Any] = [
            "daysSince": Timestamp.init(),
            "duration": String(duration),
            "helperUserName": self.username!,
            "helperRating": Int(round(self.ratingSlider.value)),
            "helperReview": self.feedbackMessage.text!,
            "helpSeekerUserName": self.helpSeekerUsername!,
            "isCompleted": false
        ]
        
        let document = db.collection("sessions").addDocument(data: data) { err in
            if err == nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.sessionId = document.documentID
    }
}
