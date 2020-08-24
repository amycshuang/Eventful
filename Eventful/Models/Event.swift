//
//  Event.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/9/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class Event {
    var eventName: String
    var eventDate: String
    var eventStartTime: String
    var eventEndTime: String
    var eventLocation: String
    var eventLocationDetailed: String
    var eventDescription: String
    var eventTags: [String]
    var eventImageUrl: String
    var eventImage: UIImage!
    var isFavorite: Bool

    init(eventName: String, eventDate: String, eventStartTime: String, eventEndTime: String, eventLocation: String, eventLocationDetailed: String, eventDescription: String, eventTags: [String], eventImageUrl: String, eventImage: UIImage, isFavorite: Bool) {
        self.eventName = eventName
        self.eventDate = eventDate
        self.eventStartTime = eventStartTime
        self.eventEndTime = eventEndTime
        self.eventLocation = eventLocation
        self.eventLocationDetailed = eventLocationDetailed
        self.eventDescription = eventDescription
        self.eventTags = eventTags
        self.eventImageUrl = eventImageUrl
        self.eventImage = eventImage
        self.isFavorite = isFavorite
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        self.eventName = snapshotValue["eventName"] as! String
        self.eventDate = snapshotValue["eventDate"] as! String
        self.eventStartTime = snapshotValue["eventStartTime"] as! String
        self.eventEndTime = snapshotValue["eventEndTime"] as! String
        self.eventLocation = snapshotValue["eventLocation"] as! String
        self.eventLocationDetailed = snapshotValue["eventLocationDetailed"] as! String
        self.eventDescription = snapshotValue["eventDescription"] as! String
        self.eventTags = snapshotValue["eventTags"] as! [String]
        self.eventImageUrl = snapshotValue["eventImageUrl"] as! String
        self.eventImage = UIImage()
        self.isFavorite = snapshotValue["isFavorite"] as! Bool
    }
}

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return
            lhs.eventName == rhs.eventName && lhs.eventDate == rhs.eventDate && lhs.eventStartTime == rhs.eventStartTime && lhs.eventEndTime == rhs.eventEndTime && lhs.eventLocation == rhs.eventLocation && lhs.eventLocationDetailed == rhs.eventLocationDetailed && lhs.eventDescription == rhs.eventDescription
    }
}
