//
//  Messages.swift
//  Uppercase
//
//  Created by The Techy Hub on 16/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import Foundation

struct Message: Decodable {
    let id: Int
    let chat_id: Int
    let sender: [Member]
    var text: String
    let sent_at: String
}
