//
//  PrivateChat.swift
//  Uppercase
//
//  Created by The Techy Hub on 10/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import Foundation

struct PrivateChat: Decodable {
    var id: Int
    let host: Member
    var guest: Member
    let updated_at: String
}
