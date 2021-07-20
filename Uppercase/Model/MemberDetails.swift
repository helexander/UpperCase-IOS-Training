//
//  MemberDetails.swift
//  Uppercase
//
//  Created by The Techy Hub on 08/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import Foundation

struct MemberDetails: Decodable {
    let id: Int
    var first_name: String
    var last_name: String
    var email: String
    var phone_number: String
    let avatar: String?
    var join_date: String
    var company: CompanyInfo
}
