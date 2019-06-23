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
    
    var questions: [Question] = []
    var score: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let a1 = Answer(text: "Best", type: .best)
        let a2 = Answer(text: "Good", type: .good)
        let a3 = Answer(text: "Bad", type: .bad)
        let a4 = Answer(text: "Worst", type: .worst)
        let answers = [a1,a2,a3,a4]
        
        let a12 = Answer(text: "Yes", type: .best)
        let a22 = Answer(text: "No", type: .good)
        let a32 = Answer(text: "MAYBE", type: .bad)
        let a42 = Answer(text: "SURE", type: .worst)
        let answers2 = [a12,a22,a32,a42]
        
        let q1 = Question(ID: "1", text: "First Question?", usertype: .Volunteer, answers: answers)
        let q2 = Question(ID: "2", text: "Second Question?", usertype: .Volunteer, answers: answers2)
        let q3 = Question(ID: "3", text: "Third Question?", usertype: .Volunteer, answers: answers)
        let q4 = Question(ID: "4", text: "Fourth Question?", usertype: .Volunteer, answers: answers2)

        questions = [q1,q2,q3,q4]
        
    }
    
    @IBAction func submited(_ sender: Any) {
//        self.score = 0
//
//        for question in questions {
//            self.score =  self.score! + question.answerScore
//        }
//
//        print(score!)
    }
    
    func answerChanged(id: String, answer: Int) {
//        var count = 0
//        for question in questions {
//            if question.id == id {
//                questions[count].userAnswer = answer
//            }
//            count += 1
//        }
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
