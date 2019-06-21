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
    var selectedQuestion: String?
    var userType: String?
    
    @IBOutlet weak var QuestionInput: UITextView!
    @IBOutlet weak var BestAnswer: UITextField!
    @IBOutlet weak var goodAnswerInput: UITextField!
    @IBOutlet weak var badAnswerInput: UITextField!
    @IBOutlet weak var worstAnswerInput: UITextField!
    @IBOutlet weak var AddEditButton: UIBarButtonItem!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if let question = self.selectedQuestion {
            
            db.collection("qustions").whereField("question", isEqualTo: question)
                .getDocuments() { (querySnapshot, err) in
                    
                    if let data = querySnapshot?.documents[0].data() {
                        self.QuestionInput.text = data["question"] as? String
                        if let answers = data["answers"] as? [String: String] {
                            self.BestAnswer.text = answers["best"]
                            self.goodAnswerInput.text = answers["good"]
                            self.badAnswerInput.text = answers["bad"]
                            self.worstAnswerInput.text = answers["worst"]
                        }
                    }
            }
            
        }else {
            navigationItem.title = "Add Question"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(AddQuestionTableViewController.AddClicked(_:)))

        }
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
                .document(self.QuestionInput.text!)
                .setData(docData, merge: true)
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Question updated!")
                    }
            }
        
        
        dismiss(animated: true, completion: nil)

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
    




