//
//  QuestionsTableViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/19/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class QuestionsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UserCellDelegate {

    // Google Firestore connection
    var db: Firestore!
    var storage: Storage!
    
    @IBOutlet weak var QuestionsTable: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!
    
    
    var selectedQuestion: String?
    var userType: String?
    
    var questions: [Question] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        
        loadQuestions(userType: "help-seeker", searchText: nil)
        
        SearchBar.delegate = self
        QuestionsTable.delegate = self
        QuestionsTable.dataSource = self
    }
    
    
    
    @IBAction func requestedButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "EditQuestion", sender: nil)
    }
    @IBAction func addButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "AddQuestion", sender: nil)
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        if let text = searchBar.text {
            questions = []
            self.QuestionsTable.reloadData()
            
            loadQuestions(userType: "help-seeker", searchText: text)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        questions = []
        self.QuestionsTable.reloadData()
        loadQuestions(userType: "help-seeker", searchText: nil)
        
        searchBar.resignFirstResponder()
    }
    
    
    @IBAction func filterClicked(_ sender: UISegmentedControl) {
        questions = []
        self.QuestionsTable.reloadData()

        if (sender.selectedSegmentIndex == 0) {
            loadQuestions(userType: "help-seeker", searchText: nil)
            self.userType = "help-seeker"
        } else if (sender.selectedSegmentIndex == 1) {
            loadQuestions(userType: "volunteer", searchText: nil)
            self.userType = "volunteer"
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func loadQuestions(userType: String, searchText: String?) {
        let collection = db.collection("qustions")
        var query: Query?
        
        if userType != "all" {
            print("\(userType) usertype")
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
                    self.addQuestion(querySnapshot!.documents)
                }
            }
            
        } else {
            query?.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.addQuestion(querySnapshot!.documents)
                }
            }
        }
    }
    
    func addQuestion(_ documents: [QueryDocumentSnapshot]) {
        for document in documents {
            // Get the volunteer name of the document
            let question = document.data()["question"] as! String
            self.selectedQuestion = question
            let userType = document.data()["userType"] as! String
            var userTypeCase: Usertype
            if userType == "help-seeker" {
                userTypeCase = .helpSeeker
            } else {
                userTypeCase = .Volunteer
            }
            self.userType = userType

            let qusetion = Question(text: question, usertype: userTypeCase, answers: [Answer(text: "", type: .good)])
            print(qusetion)
            self.questions.append(qusetion)
        }
        
        QuestionsTable.reloadData()
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "QuestionCell") as? AdminSettingCellTableView
        
        cell?.qustion.text = self.questions[indexPath.row].text
        if self.questions[indexPath.row].usertype == .helpSeeker {
            cell?.userType.text = "help-seeker"
        } else {
            cell?.userType.text = "volunteer"
        }
        cell?.delegate = self
        
        
        return cell!
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditQuestion" {
            if segue.destination is AddQuestionTableViewController
            {
                let view = segue.destination as? AddQuestionTableViewController
                view?.selectedQuestion = self.selectedQuestion
                view?.userType = self.userType
            }
        } else if segue.identifier == "AddQuestion" {
            if segue.destination is AddQuestionTableViewController
            {
                let view = segue.destination as? AddQuestionTableViewController
                if self.userType == nil {
                    self.userType = "help-seeker"
                }
                view?.userType = self.userType
            }
        }
    }
    
    
    
    
    
    

}
