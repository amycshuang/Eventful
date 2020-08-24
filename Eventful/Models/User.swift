//
//  User.swift
//  Eventful
//
//  Created by Amy Chin Siu Huang on 5/13/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import Alamofire

class User {
    static var name: String?
    static var email: String?
    static var imageURL: String?
    static var likedEvents: [Event] = []
    static var userPosts: [Event] = []
}
