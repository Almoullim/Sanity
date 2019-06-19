//
//  Request.swift
//  Sanity
//
//  Created by Ali on 6/19/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import Foundation

class Request {
    var requestID: String
    var helpSeekerUserName: String
    var helpSeekerName: String
    var helpSeekerMobile: String
    var helperUserName: String?
    var createdAt: String
    var getDaysSince: String {
        get {
            return "Requested " + self.createdAt
        }
    }

    init() {
        requestID = ""
        helpSeekerUserName = ""
        helperUserName = ""
        helpSeekerName = ""
        helpSeekerMobile = ""
        createdAt = ""
    }
    
    convenience init?(helpSeekerUserName: String, helpSeekerName: String, helpSeekerMobile: String, helperUserName: String, createdAt: String){
        self.init()
        self.helpSeekerUserName = helpSeekerUserName
        self.helpSeekerName = helpSeekerName
        self.helperUserName = helperUserName
        self.helpSeekerMobile = helpSeekerMobile
        self.createdAt = createdAt
    }
    
    convenience init?(helpSeekerUserName: String, helpSeekerName: String, helpSeekerMobile: String, createdAt: String){
        self.init()
        self.helpSeekerUserName = helpSeekerUserName
        self.helpSeekerName = helpSeekerName
        self.helpSeekerMobile = helpSeekerMobile
        self.createdAt = createdAt
    }
}
