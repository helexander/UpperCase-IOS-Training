//
//  GroupDetailsViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 24/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class GroupDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var memberDetailsTable: UITableView!
    @IBOutlet weak var editTitleTextField: UITextField!
    @IBOutlet weak var exitButton: UIButton!
    
    var groupMembersArray : GroupChat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMembers {
            DispatchQueue.main.async {
                self.memberDetailsTable.reloadData()
            }
        }
        
        memberDetailsTable.delegate = self
        memberDetailsTable.dataSource = self
        
        exitButton.backgroundColor = UIColor.red
        exitButton.setTitle("Exit Group", for: .normal)
        exitButton.tintColor = UIColor.white
        
        editTitleTextField.text = "\(chatName)"
        changeGroupName()
        
        self.hideKeyboardWhenTappedAround()
        memberDetailsTable.keyboardDismissMode = .onDrag
        
    }
    
    @IBAction func exitGroup(_ sender: UIButton) {
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memberDetailsTableCell") as? GroupDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        //Shows the host information first
        let urlString = "\(String(describing: groupMembersArray?.host.avatar))"
        if urlString == "nil" {
            cell.displayMemberImage.image = UIImage(named: "Hat")
        } else {
            let urlString = "\((groupMembersArray?.members[indexPath.row].avatar)!)"
            let url = URL(string: urlString)
            cell.displayMemberImage.downloadedFrom(url: url!)
        }
        
        cell.memberNameLabel.text = "\(String(describing: groupMembersArray?.members[indexPath.row].first_name)) \(String(describing: groupMembersArray?.members[indexPath.row].last_name))"
        cell.memberBioLabel.text = "Hi! I'm an uppercase member!"
        cell.memberAdminLabel.text = "Admin"
        
        //Shows all the member details
        let memberUrlString = "\(String(describing: groupMembersArray?.members[indexPath.row].avatar))"
        if memberUrlString == "nil" {
            cell.displayMemberImage.image = UIImage(named: "Hat")
        } else {
            let memberUrlString = "\((groupMembersArray?.members[indexPath.row].avatar)!)"
            let url = URL(string: memberUrlString)
            cell.displayMemberImage.downloadedFrom(url: url!)
        }
        cell.memberNameLabel.text = "\(String(describing: groupMembersArray?.members[indexPath.row].first_name)) \(String(describing: groupMembersArray?.members[indexPath.row].last_name))"
        cell.memberBioLabel.text = "Hi! I'm an uppercase member!"
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRow = groupMembersArray?.members.count
        
        return 6
    }
    
    func getMembers(completed: @escaping() -> ()) {
        let myUrl = URL(string: "\(base_url)/group-chats/\(currentGroupID)/?include=members")
        var request = URLRequest(url:myUrl!)
        print(request)
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
                self.groupMembersArray = try
                    JSONDecoder().decode(GroupChat.self, from:data!)
                
                //self.groupMembersArray = memberDetails
                
                //print("Member count: \(memberDetails.members.count)")
                
                DispatchQueue.main.async {
                    completed()
                }
                
                
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
                print(error)
            }
        }
        task.resume()
    }
    
    func changeGroupName() {
        
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
