//
//  ReusableFunctions.swift
//  Uppercase
//
//  Created by The Techy Hub on 04/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

let base_url = "http://app-uppercase.techy.my:8080/api/v1"

//Sets the navigation bar's fonts
let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 17)!]

//Obtains the current logged in user's ID [Obtained from Sign In Controller]
var userIdDetails = ""

//Retrieve a string value from keychain:
var accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
var userId: String? = KeychainWrapper.standard.string(forKey: "userId")

//Check if the user is going for an EVENT or not {Used in EventDetailsController}
var goingState = true

//Obtain the chat title of a chat and assign it to the child view's navigation title so it will display the chat's respective recipient/group
var chatName = ""

//To pass the ID of a host/guest of the current indexRow of a selected table cell {Used in ChatsViewController}
var currentID = 0

var currentGroupID = 0

var cellSelection = 0

var getHostID = 0

var getGroupHostID = 0

var found = false

var chatID = 0

var currentFirstName = ""
var currentLastName = ""
var currentPhoneNum = ""


