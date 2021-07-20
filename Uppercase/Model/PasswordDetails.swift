//
//  PasswordDetails.swift
//  Uppercase
//
//  Created by The Techy Hub on 26/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import Foundation

struct PasswordDetail: Decodable {
    var current_password: String
    var password: String
    var password_confirmation: String
}
