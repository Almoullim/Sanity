//
//  VolunteerQuestionsViewController.swift
//  Sanity
//
//  Created by Ali on 6/23/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class VolunteerQuestionsViewController: UITableViewController, QuestionCellDelegate {
    
    @IBOutlet var questionsTable: UITableView!
    var db: Firestore!

    var questions: [Question] = []
    var score: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()

        db.collection("qustions").getDocuments() { querySnapshot, err in
            let questions = querySnapshot?.documents
            
            for question in questions! {
                let questionData = question.data()
                let questionDataAnswers = questionData["answers"]! as! Dictionary<String, String>
                let questionAnswers = [
                    Answer(text: questionDataAnswers["best"]!, rate: .best),
                    Answer(text: questionDataAnswers["good"]!, rate: .good),
                    Answer(text: questionDataAnswers["bad"]!, rate: .bad),
                    Answer(text: questionDataAnswers["worst"]!, rate: .worst)
                ]
                
                let questionObj = Question(ID: question.documentID, text: questionData["question"] as! String, usertype: .Volunteer, answers: questionAnswers, userAnswer: .best)
                self.questions.append(questionObj)
                
                self.questionsTable.reloadData()
            }
        }
    }
    
    @IBAction func submited(_ sender: Any) {
        self.score = 0

        for question in questions {
            switch question.userAnswer! {
            case Rate.best:
                self.score = self.score! + 3
                break
            case Rate.good:
                self.score = self.score! + 2
                break
            case Rate.bad:
                self.score = self.score! + 1
                break
            case Rate.worst:
                self.score = self.score! + 0
                break
            }
        }

        print(score!)
        
        let passScore = (questions.count * 4) / 2
        
        if score! > passScore {
            print("Pass")
            
            let alert = UIAlertController(title: "You have passed the exam!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { action in
                self.performSegue(withIdentifier: "RegisterView", sender: nil)
            }))
            self.present(alert, animated: true)
        } else {
            print("Failed")
            
            let alert = UIAlertController(title: "You have failed the exam!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { action in
                self.performSegue(withIdentifier: "LoginView", sender: nil)
            }))
            self.present(alert, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterView" {
            let nav = segue.destination as? UINavigationController
            let view = nav?.viewControllers.first as? RegisterViewController
            view?.userType = "doctor"
        }
    }
    
    func answerChanged(id: String, answer: Int) {
        var count = 0
        for question in questions {
            if question.ID == id {
                questions[count].userAnswer = question.answers[answer].rate
            }
            count += 1
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "QuestionCell") as? QuestionCell else { return UITableViewCell() }
        
        cell.questionTitle.text = questions[indexPath.row].text
        cell.questionId = questions[indexPath.row].ID
        
        cell.questionAnswerController.setTitle(questions[indexPath.row].answers[0].text, forSegmentAt: 0)
        cell.questionAnswerController.setTitle(questions[indexPath.row].answers[1].text, forSegmentAt: 1)
        cell.questionAnswerController.setTitle(questions[indexPath.row].answers[2].text, forSegmentAt: 2)
        cell.questionAnswerController.setTitle(questions[indexPath.row].answers[3].text, forSegmentAt: 3)
        
        cell.delegate = self
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return questions.count
        }
        return 0
    }
}
