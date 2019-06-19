//
//  Session.swift
//  Sanity
//
//  Created by Ali Hubail on 6/18/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import Foundation

class Session {
    var sessionID: String
    var helpSeekerUserName: String
    var helperUserName: String
    var duration: String
    var helpSeekerReview: String
    var helperReview: String
    var helpSeekerRateing: Int
    var helperRating: Int
    var daysSince: String
    var getDaysSince: String {
        get {
            return "since " + self.daysSince
        }
    }
    
    init() {
        sessionID = ""
        helpSeekerUserName = ""
        helperUserName = ""
        duration = ""
        helpSeekerReview = ""
        helperReview = ""
        helpSeekerRateing = 0
        helperRating = 0
        daysSince = ""
        var getDaysSince: String {
            get {
                return "Member since " + self.daysSince
            }
        }
        
    }
    convenience init?(sessionID: String, helpSeekerUserName: String, helperUserName: String, daysSince: String) {
        self.init()
        self.sessionID = sessionID
        self.helpSeekerUserName = helpSeekerUserName
        self.helperUserName = helperUserName
        self.duration = ""
        self.daysSince = daysSince
        
        self.helpSeekerReview = ""
        self.helperReview = ""
        self.helpSeekerRateing = 0
        self.helperRating = 0
    }
    convenience init?(sessionID: String, helpSeekerUserName: String, helperUserName: String, duration: String, helpSeekerReview: String, helperReview: String, helpSeekerRateing: Int, helperRating: Int , daysSince: String) {
        self.init()
        self.sessionID = sessionID
        self.helpSeekerUserName = helpSeekerUserName
        self.helperUserName = helperUserName
        self.duration = duration
        self.helpSeekerReview = helpSeekerReview
        self.helperReview = helperReview
        self.helpSeekerRateing = helpSeekerRateing
        self.helperRating = helperRating
        self.daysSince = daysSince
        
    }
}

class Appointment {
    var appointmentID: String
    var helpSeekerUserName: String
    var helperUserName: String
    var date: String
    var time: String
    var createAt: String
    var getDaysSince: String {
        get {
            return "Member since " + self.createAt
        }
    }
    
    init() {
        appointmentID = ""
        helpSeekerUserName = ""
        helperUserName = ""
        date = ""
        time = ""
        createAt = ""
    }
    convenience init?(appointmentID: String, helpSeekerUserName: String, helperUserName: String, date: String, time: String, createAt: String){
        self.init()
        self.appointmentID = appointmentID
        self.helpSeekerUserName = helpSeekerUserName
        self.helperUserName = helperUserName
        self.date = date
        self.time = time
        self.createAt = createAt
    }
}
