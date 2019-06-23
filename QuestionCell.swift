//
//  QuestionCell.swift
//  Sanity
//
//  Created by Ali on 6/23/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

protocol QuestionCellDelegate: class {
    func answerChanged(id: String, answer: Bool)
}

class QuestionCell: UITableViewCell {

    @IBOutlet weak var questionTitle: UILabel!
//    @IBOutlet weak var questionAnswerController: UISegmentedControl!
    
    var questionId: String?
    var questionAnswer: Bool?
    var delegate: QuestionCellDelegate?
    
    @IBAction func answerChanged(_ sender: UISegmentedControl) {
        self.questionAnswer = sender.selectedSegmentIndex == 0
        delegate?.answerChanged(id: questionId!, answer: questionAnswer!)
    }
    
}
