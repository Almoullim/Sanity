//
//  QuestionCell.swift
//  Sanity
//
//  Created by Ali on 6/23/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

protocol QuestionCellDelegate: class {
    func answerChanged(id: String, answer: Int)
}

class QuestionCell: UITableViewCell {

    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var questionAnswerController: UISegmentedControl!
    
    var questionId: String?
    var questionAnswer: Int?
    var delegate: QuestionCellDelegate?
    
    @IBAction func answerChanged(_ sender: Any?) {
        self.questionAnswer = questionAnswerController.selectedSegmentIndex
        delegate?.answerChanged(id: questionId!, answer: questionAnswer!)
    }
    
}
