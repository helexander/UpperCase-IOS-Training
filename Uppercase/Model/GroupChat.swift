//
//  GroupChat.swift
//  Uppercase
//
//  Created by The Techy Hub on 10/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import Foundation

struct GroupChat: Decodable {
    let id: Int
    let title: String
    let host: Member
    let updated_at: String
    var is_member: Bool
    let members: [Member]
}
