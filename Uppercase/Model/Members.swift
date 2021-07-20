//
//  Members.swift
//  Uppercase
//
//  Created by The Techy Hub on 03/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import Foundation


struct Member:Decodable {
    var id: Int
    let first_name: String
    let last_name: String
    let email: String
    let phone_number: String
    let avatar: String?
    let join_date: String
}

