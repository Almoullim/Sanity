//
//  DoctorQuestionsViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/25/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase
class DoctorQuestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, AdminSettingDelegate  {
    
    // Google Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    // outlet
    @IBOutlet weak var QuestionsTable: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!
    
    // pass info
    var selectedQuestion: String?
    var userType: String?
    
    var questions: [Question] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // firebase api coce
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        // load help seeker question(default fillter)
        loadQuestions(userType: "volunteer", searchText: nil)
        
        // dalegate
        SearchBar.delegate = self
        QuestionsTable.delegate = self
        QuestionsTable.dataSource = self
        
    }
    
    
    func segueWith(ID: String) {
        selectedQuestion = ID
        requestedButtonClicked(self)
    }
    @IBAction func requestedButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "EditQuestion", sender: nil)
    }
    @IBAction func addButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "AddQuestion", sender: nil)
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        // get search text and reload sessions
        if let text = searchBar.text {
            questions = []
            self.QuestionsTable.reloadData()
            
            loadQuestions(userType: "volunteer", searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // discharge search and reload all sessions
        searchBar.text = nil
        questions = []
        self.QuestionsTable.reloadData()
        loadQuestions(userType: "volunteer", searchText: nil)
        
        searchBar.resignFirstResponder()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // get questions count and assign to rows count
        return questions.count
    }
    
    func loadQuestions(userType: String, searchText: String?) {
        // set collection [table]
        let collection = db.collection("qustions")
        // set query
        var query = collection.whereField("userType", isEqualTo: userType)
        
        if searchText != nil {
            // set search query
            query = collection.order(by: "name").start(at: [searchText!]).end(at: [searchText! + "\u{f8ff}"])
        }
        // get document
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.addQuestion(querySnapshot!.documents)
            }
        }
    }
    
    func addQuestion(_ documents: [QueryDocumentSnapshot]) {
        // get each documnt info and assign to new question
        for document in documents {
            // Get the volunteer name of the document
            let questionID = document.documentID
            self.selectedQuestion = questionID
            let question = document.data()["question"] as! String
            let userType = document.data()["userType"] as! String
            var userTypeCase: Usertype
                userTypeCase = .helpSeeker
            
            self.userType = userType
            
            let qusetion = Question(ID: questionID, text: question, usertype: userTypeCase, answers: [Answer(text: "", rate: .good)], userAnswer: nil)
            
            // add new quetion to the collection
            self.questions.append(qusetion)
        }
        
        QuestionsTable.reloadData()
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // assign quetion info to cell
        let cell =  tableView.dequeueReusableCell(withIdentifier: "QuestionCell") as? AdminSettingCellTableView
        
        cell?.qustion.text = self.questions[indexPath.row].text
        cell?.userType.text = "volunteer"
        cell?.ID = self.questions[indexPath.row].ID
        cell?.delegate = self
        
        return cell!
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // pass info to next view
        if segue.identifier == "EditQuestion" {
            if segue.destination is DoctorAddQuestionViewController
            {
                let view = segue.destination as? DoctorAddQuestionViewController
                view?.selectedQuestion = self.selectedQuestion
                view?.userType = self.userType
            }
        } else if segue.identifier == "AddQuestion" {
            if segue.destination is DoctorAddQuestionViewController
            {
                let view = segue.destination as? DoctorAddQuestionViewController
                
                view?.userType = "volunteer"
            }
        }
    }
    
    
    @IBAction func unwindToDoctorQustions(unwindSegue: UIStoryboardSegue) {
        // unwind from add/edit question
        questions = []
        loadQuestions(userType: "volunteer", searchText: nil)
        self.QuestionsTable.reloadData()
    }
    
    
    

}
