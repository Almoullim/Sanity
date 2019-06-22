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
    
    
    // outlet
    @IBOutlet weak var QuestionInput: UITextView!
    @IBOutlet weak var BestAnswer: UITextField!
    @IBOutlet weak var goodAnswerInput: UITextField!
    @IBOutlet weak var badAnswerInput: UITextField!
    @IBOutlet weak var worstAnswerInput: UITextField!
    @IBOutlet weak var AddEditButton: UIBarButtonItem!
    
    // firebase connection
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // firebase api code
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get user info if there is passed information
        if let question = self.selectedQuestion {
            let docRef = db.collection("qustions").document(question)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    if let data = document.data() {
                        self.QuestionInput.text = data["question"] as? String
                        if let answers = data["answers"] as? [String: String] {
                            self.BestAnswer.text = answers["best"]
                            self.goodAnswerInput.text = answers["good"]
                            self.badAnswerInput.text = answers["bad"]
                            self.worstAnswerInput.text = answers["worst"]
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
        }else {
            // change title and button type if there isn't passed information
            self.navigationItem.title = "Add Question"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(AddQuestionTableViewController.AddClicked(_:)))
            
        }
    }
    
    
    @IBAction func AddClicked(_ sender: Any) {
        // go back to questions list
        performSegue(withIdentifier: "questions", sender: nil)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "questions" {
            
            if segue.destination is QuestionsTableViewController
            {
                // pass userType back
                let view = segue.destination as? QuestionsTableViewController
                view?.userType = self.userType
            }
            // get data from outlets and insert/ overwrite information to database
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
            if let qustionID = self.selectedQuestion {
            self.db
                .collection("qustions")
                .document(qustionID)
                .setData(docData, merge: true)
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Question updated!")
                    }
                }
            } else {
                self.db
                    .collection("qustions")
                    .document()
                    .setData(docData, merge: true)
                    { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Question updated!")
                        }
            }
        }
    }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
    




