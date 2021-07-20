//
//  PrivateMessages.swift
//  Uppercase
//
//  Created by The Techy Hub on 17/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import Foundation

struct PrivateMessage: Decodable {
    let id: Int
    let sender: Member
    var text: String
    let sent_at: String
}
