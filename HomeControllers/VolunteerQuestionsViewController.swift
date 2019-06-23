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
//
//        let q1 = Question2(id: "1", title: "First Question", userAnswer: true, answerShouldBe: true)
//        let q2 = Question2(id: "2", title: "Second Question", userAnswer: true, answerShouldBe: true)
//        let q3 = Question2(id: "3", title: "Third Question", userAnswer: true, answerShouldBe: true)
//        let q4 = Question2(id: "4", title: "Fourth Question", userAnswer: true, answerShouldBe: true)
//
//        questions = [q1,q2,q3,q4]
        
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
        print("Building Cell")
//        cell.questionTitle.text = questions[indexPath.row].title
//        cell.questionId = questions[indexPath.row].id
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
