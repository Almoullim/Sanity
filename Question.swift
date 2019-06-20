//
//  Question.swift
//  Sanity
//
//  Created by Ali Hubail on 6/15/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import Foundation

struct Question {
    var text: String
    var usertype: Usertype
    var answers: [Answer]
}
enum Usertype {
    case helpSeeker, Volunteer
}

struct Answer {
    var text: String
    var type: Rate
}

enum Rate {
    case veryGood,good,bad,VeryBad
}
