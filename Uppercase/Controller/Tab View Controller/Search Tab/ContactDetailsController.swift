//
//  ContactDetailsController.swift
//  Uppercase
//
//  Created by The Techy Hub on 09/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ContactDetailsController: UIViewController {
    
    @IBOutlet weak var nameDetailedContacts: UILabel!
    @IBOutlet weak var defaultMessageDetailedContacts: UILabel!
    @IBOutlet weak var durationCompanyDetailedContacts: UILabel!
    @IBOutlet weak var descriptionDetailedContacts: UILabel!
    @IBOutlet weak var imageDetailedContacts: UIImageView!
    
    var contacts : Member?
    var searchPrivateChat = [PrivateChat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadContact()
        
        //If the chat exists then GET if not then do a POST method
        checkChat()
        
    }

    @IBAction func messageButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showSearchPrivateChat", sender: self)
    }
    
    func loadContact() {        
        if let contactID = contacts?.id {
            currentID = contactID
            
            let myUrlContact = URL(string: "\(base_url)/members/\(String(describing: (contactID)))")
            var requestContact = URLRequest(url:myUrlContact!)
            requestContact.httpMethod = "GET"
            requestContact.addValue(accessToken!, forHTTPHeaderField: "Authorization")
            requestContact.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: requestContact) { (data: Data?, response: URLResponse?, error: Error?) in
                
                if error != nil
                {
                    self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                    print("error=\(String(describing: error))")
                    return
                }
                
                do {
                    let memberCompanyDetails = try
                    JSONDecoder().decode(MemberDetails.self, from: data!)
                    
                    //Pass the name to the chat
                    chatName = "\(memberCompanyDetails.first_name) \(memberCompanyDetails.last_name)"
                    
                    currentID = memberCompanyDetails.id
                    currentFirstName = memberCompanyDetails.first_name
                    currentLastName = memberCompanyDetails.last_name
                    currentPhoneNum = memberCompanyDetails.phone_number
    
                    DispatchQueue.main.async {
                        
                        let urlString = "\(String(describing: memberCompanyDetails.avatar))"
                        
                        if urlString == "nil" {
                            self.imageDetailedContacts.image = UIImage(named: "Contact4")
                        } else {
                            let urlString = "\((memberCompanyDetails.avatar)!)"
                            let url = URL(string: urlString)
                            self.imageDetailedContacts.downloadedFrom(url: url!)
                        }
                    
                        self.nameDetailedContacts.text = "\(memberCompanyDetails.first_name) \(memberCompanyDetails.last_name)"
                        self.descriptionDetailedContacts.text = "\(memberCompanyDetails.company.position) at \(memberCompanyDetails.company.name)"
                        self.durationCompanyDetailedContacts.text = "From \(memberCompanyDetails.company.join_date) to \(memberCompanyDetails.company.leave_date)"
                        self.defaultMessageDetailedContacts.text = "Hi There! I am using Uppercase"
                    }
                } catch {
                    self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
                    print(error)
                }
                
            }
            task.resume()
        }
        
    }
    
    func checkChat() {
        let myUrl = URL(string: "\(base_url)/private-chats")
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "GET"
        request.addValue(accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                self.searchPrivateChat = try
                    JSONDecoder().decode([PrivateChat].self, from: data!)
                
                //Checks the database to see whether the chat with the selected user exists or not
                for i in 0..<self.searchPrivateChat.count {
                    if(self.searchPrivateChat[i].host.id == currentID || self.searchPrivateChat[i].guest.id == currentID)  {
                        found = true
                        break
                    } else {
                        found = false
                    }
                }
                
                print("An ID was found: \(found)")
                
            } catch {
                // Display an Alert dialog with a friendly error message
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print(error)
            }
            
        }
        
        task.resume()
        
    }
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
}
