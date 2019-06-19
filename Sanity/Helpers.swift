//
//  Helpers.swift
//  Sanity
//
//  Created by Ali on 5/28/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import Foundation
import Firebase

func timeSince(timestamp: Timestamp) -> String {
    // Construct days since
    let seconds = Int64(Date().timeIntervalSince1970) - timestamp.seconds
    let hours = (seconds / 3600)
    let days = (seconds / 86400)
    let months = days / 30
    let years = days / 365
    var timeSince = ""
    if hours < 24 {
        timeSince = String(hours) + (days > 1 ? " hours" : " hour")
    }else if days < 31 {
        timeSince = String(days) + (days > 1 ? " days" : " day")
    } else if months < 12 {
        timeSince = String(months) + (months > 1 ? " months" : " month")
    } else {
        timeSince = String(years) + (years > 1 ? " years" : " year")
    }
    
    return timeSince
}

func duration(duration: String) -> String {
    let durationInt = Int(duration)
    let seconds = durationInt
    let hours = (seconds! / 3600)
    let days = (seconds! / 86400)
    let months = days / 30
    let years = days / 365
    var durationString = ""
    if hours < 24 {
        durationString = String(hours) + (days > 1 ? " hours" : " hour")
    }else if days < 31 {
        durationString = String(days) + (days > 1 ? " days" : " day")
    } else if months < 12 {
        durationString = String(months) + (months > 1 ? " months" : " month")
    } else {
        durationString = String(years) + (years > 1 ? " years" : " year")
    }
    
    return durationString
}
