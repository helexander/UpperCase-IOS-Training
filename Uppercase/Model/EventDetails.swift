//
//  EventDetails.swift
//  Uppercase
//
//  Created by The Techy Hub on 04/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import Foundation

struct EventDetails: Decodable {
    var id: Int
    let title: String
    let description: String
    let location: String
    let cover: String?
    let date: String
    var rsvp_count: Int
    var is_going: Bool
}
