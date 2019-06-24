//
//  HelpSeekerFeedbackViewController.swift
//  Sanity
//
//  Created by Ali on 6/25/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class HelpSeekerFeedbackViewController: UITableViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var feedbackMessage: UITextView!
    @IBOutlet weak var ratingSlider: UISlider!
    
    var db: Firestore!
    var sessionId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.hideKeyboardWhenTappedAround()
        
        db.collection("sessions").document(sessionId!).getDocument() { document, err in
            let data = document?.data()
        
            let username = data!["helperUserName"] as? String
            
            self.db.collection("users").whereField("username", isEqualTo: username!).getDocuments() { querySnapshot, err in
                if err == nil {
                    if let data = querySnapshot?.documents[0].data() {
                        if let name = data["name"] as? String {
                            self.name.text = name
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func saveFeedback(_ sender: Any) {
        let data: [String: Any] = [
            "helpSeekerRating": Int(round(self.ratingSlider.value)),
            "helpSeekerReview": self.feedbackMessage.text!,
            "isCompleted": true
        ]
        
       db.collection("sessions").document(self.sessionId!).setData(data, merge: true) { err in
            self.performSegue(withIdentifier: "HelpSeeker", sender: nil)
        }
    }
}
