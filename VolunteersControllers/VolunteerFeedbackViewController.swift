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
    }
    
    @IBAction func saveFeedback(_ sender: Any) {
        var data: [String: Any] = [
            :
        ]
        
        db.collection("sessions").addDocument(data: data)
    }
}
