//
//  QuestionCell.swift
//  Sanity
//
//  Created by Ali on 6/23/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {

    @IBOutlet weak var questionTitle: UILabel!
//    @IBOutlet weak var questionAnswerController: UISegmentedControl!
    
    var questionId: String?
    var questionAnswer: Bool?
    
    @IBAction func answerChanged(_ sender: UISegmentedControl) {
        
        self.questionAnswer = sender.selectedSegmentIndex == 0
    }
    
}
