//
//  Response.swift
//  Uppercase
//
//  Created by The Techy Hub on 03/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import Foundation

struct UppercaseResponse:Decodable {
    let token: String
    let current_member: Member
}

