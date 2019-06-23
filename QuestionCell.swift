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
    @IBOutlet weak var questionAnswerController: UISegmentedControl!
    
    var questionId: String?
    var questionAnswer: Bool?
    var delegate: QuestionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        answerChanged(nil)
    }
    
    @IBAction func answerChanged(_ sender: Any?) {
        self.questionAnswer = questionAnswerController.selectedSegmentIndex == 0
        delegate?.answerChanged(id: questionId!, answer: questionAnswer!)
    }
    
}
