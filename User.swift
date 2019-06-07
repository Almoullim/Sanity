//
//  User.swift
//  Sanity
//
//  Created by Ali on 5/26/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import Foundation

class User {
    var username: String
    var name: String
    var daysSince: String
    var getDaysSince: String {
        get {
            return "Member since " + self.daysSince
        }
    }
    
    init() {
        username = ""
        name = ""
        daysSince = ""
    }
    
    convenience init?(username: String, name: String, daysSince: String) {
        self.init()
        self.username = username
        self.name = name
        self.daysSince = daysSince
    }
}

class Volunteer: User {
    
}

class Doctor: User {
    
}

class HelpSeeker: User {
    var mobile: String
    override var getDaysSince: String {
        get {
            return "Requested " + self.daysSince
        }
    }
    
    override init() {
        self.mobile = ""
        super.init()
    }
    
    convenience init?(username: String, name: String, daysSince: String, mobile: String) {
        self.init(username: username, name: name, daysSince: daysSince)
        self.mobile = mobile
    }
}
