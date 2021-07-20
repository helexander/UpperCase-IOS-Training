//
//  GroupMemberStateViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 23/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class GroupMemberStateViewController: UIViewController {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var joinGroupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupNameLabel.text = chatName
        descriptionLabel.text = "You are not a member of \(chatName)"
        
        joinGroupButton.layer.cornerRadius = 7
    }

    @IBAction func joinGroupButtonTapped(_ sender: UIButton) {
        joinChat()
        
        performSegue(withIdentifier: "joinedGroupButtonTapped", sender: self)
    }
    
    func joinChat() {
        //params for joining a chat
        let titleGroup = chatName
        
        let myURL = URL(string: "\(base_url)/group-chats/\(currentGroupID)/join")
        var request = URLRequest(url:myURL!)
        request.httpMethod = "PATCH"
        request.addValue(accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let patchString = ["title": titleGroup] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: patchString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong...(httpBody error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                var groupDetails = try
                    JSONDecoder().decode(GroupChat.self, from: data!)
                
                groupDetails.is_member = true
                
                self.displayMessage(userMessage: "Successfully joined group!")
                
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
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
