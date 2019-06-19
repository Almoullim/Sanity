//
//  AddQuestionTableViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/18/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AddQuestionTableViewController: UITableViewController {

    // pass info
    var userType: String?
    
    @IBOutlet weak var QuestionInput: UITextView!
    @IBOutlet weak var BestAnswer: UITextField!
    @IBOutlet weak var goodAnswerInput: UITextField!
    @IBOutlet weak var badAnswerInput: UITextField!
    @IBOutlet weak var worstAnswerInput: UITextField!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.hideKeyboardWhenTappedAround()
    }
    

    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddClicked(_ sender: Any) {
        let docData: [String: Any] = [
            "question": self.QuestionInput.text!,
            "userType": self.userType!,
            "answers": [
                "best": self.BestAnswer.text!,
                "good": self.goodAnswerInput.text!,
                "bad": self.badAnswerInput.text!,
                "worst": self.worstAnswerInput.text!
            ]
        ]
        
        self.db
            .collection("qustions")
            .addDocument(data: docData)
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("request created/updated!")
                    // self.dismiss(animated: true, completion: nil)
                }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    


}
