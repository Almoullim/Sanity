//
//  User.swift
//  Sanity
//
//  Created by Ali on 5/26/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import Foundation

class User {
    var name: String
    var daysSince: String
    var getDaysSince: String {
        get {
            return "Member since " + self.daysSince
        }
    }
    
    init() {
        name = ""
        daysSince = ""
    }
    
    convenience init?(name: String, daysSince: String) {
        self.init()
        self.name = name
        self.daysSince = daysSince
    }
}

class Volunteer: User {
    
}

class Doctor: User {
    
}
