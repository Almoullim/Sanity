//
//  VolunteerQuestionsViewController.swift
//  Sanity
//
//  Created by Ali on 6/23/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class VolunteerQuestionsViewController: UITableViewController {
    
    @IBOutlet var questionsTable: UITableView!
    var questions: [Question2] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let q1 = Question2(id: "1", title: "First Question", answer: nil)
        let q2 = Question2(id: "1", title: "First Question", answer: nil)
        let q3 = Question2(id: "1", title: "First Question", answer: nil)
        let q4 = Question2(id: "1", title: "First Question", answer: nil)
        
        questions = [q1,q2,q3,q4]
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "QuestionCell") as? QuestionCell else { return UITableViewCell() }
        print("Building Cell")
        cell.questionTitle.text = questions[indexPath.row].title
        cell.questionId = questions[indexPath.row].id
        
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
