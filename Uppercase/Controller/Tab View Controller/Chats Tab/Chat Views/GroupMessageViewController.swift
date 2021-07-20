//
//  GroupMessageViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 18/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class GroupMessageViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sideGroupConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomGroupConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupMessageTextField: UITextField!
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var settingMenuBar: UIView!
    @IBOutlet weak var topGroupConstraint: NSLayoutConstraint!
    
    var groupMessageArray = [GroupMessage]()
    
    var settingsMenuIsHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topGroupConstraint.constant = -140
        settingMenuBar.isHidden = true
        settingMenuBar.layer.cornerRadius = 7
        
        getMessages {
            DispatchQueue.main.async {
                self.groupTableView.reloadData()
            }
        }
        
        groupMessageTextField.delegate = self
        groupTableView.delegate = self
        groupTableView.dataSource = self
        
        groupTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "messageTableCell")
        groupTableView.register(UINib(nibName: "ReceivedMessageCell", bundle: nil) , forCellReuseIdentifier: "receivedMessageCell")
        
        navigationItem.title = "\(chatName)"
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        setUpNavigationBarItem()
        
        configureTableView()
        
        groupTableView.keyboardDismissMode = .onDrag
        self.hideKeyboardWhenTappedAround()
        
        groupTableView.separatorStyle = .none
        
        let tempImageView = UIImageView(image: UIImage(named: "darkBG"))
        tempImageView.frame = self.groupTableView.frame
        self.groupTableView.backgroundView = tempImageView
        
    }
    
    @IBAction func sendGroupMessageButtonTapped(_ sender: UIButton) {
        sendGroupMessage()
    }
    
    @IBAction func editGroupChat(_ sender: UIButton) {
        performSegue(withIdentifier: "showMemberDetails", sender: self)
    }
    
    @IBAction func exitGroupChat(_ sender: UIButton) {
        //Check to see whether the logged in user is the admin of the group
        if(getHostID == Int(userIdDetails)) {
            self.deleteConfirmMessage(userMessage: "You are an admin, leaving this group would disband the entire chat. Do you wish to continue?")
        } else {
            self.confirmMessage(userMessage: "Are you sure you want to leave this group?")
        }
    }
    
    private func setUpNavigationBarItem() {
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(#imageLiteral(resourceName: "Chat Settings"), for: .normal)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        settingsButton.addTarget(self, action: #selector(menuItemState), for: .touchUpInside)
    }
    
    @objc func menuItemState() {
        if settingsMenuIsHidden {
            topGroupConstraint.constant = 0
            settingMenuBar.isHidden = false
            
        } else {
            topGroupConstraint.constant = -140
            settingMenuBar.isHidden = true
        }
        settingsMenuIsHidden = !settingsMenuIsHidden
    }
    
    func configureTableView() {
        groupTableView.rowHeight = UITableViewAutomaticDimension
        groupTableView.estimatedRowHeight = 75.0
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.sideGroupConstraint.constant = 250
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.sideGroupConstraint.constant = 43
            self.view.layoutIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let urlString = "\(String(describing: groupMessageArray[indexPath.row].sender.avatar))"
        
        if(groupMessageArray[indexPath.row].sender.id == Int(userIdDetails)) {
            //Sent out messages
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableCell", for: indexPath) as! MessageTableViewCell
            
            cell.messageView.backgroundColor = UIColor.yellow
            
            if urlString == "nil" {
                cell.messageImage.image = UIImage(named: "Hat")
            } else {
                let urlString = "\((groupMessageArray[indexPath.row].sender.avatar)!)"
                let url = URL(string: urlString)
                cell.messageImage.downloadedFrom(url: url!)
            }
            
            cell.timeChat.text = groupMessageArray[indexPath.row].sent_at
            cell.messageTextLabel.text = groupMessageArray[indexPath.row].text
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cellSelection = Int(indexPath.row)
            
            return cell
            
        } else {
            //Recieved messages
            let cell = tableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! ReceivedMessageTableViewCell
            
            cell.receivedView.backgroundColor = UIColor.lightGray
            
            if urlString == "nil" {
                cell.receivedMessageImage.image = UIImage(named: "Hat")
            } else {
                let urlString = "\((groupMessageArray[indexPath.row].sender.avatar)!)"
                let url = URL(string: urlString)
                cell.receivedMessageImage.downloadedFrom(url: url!)
            }
            
            cell.receivedTimeLabel.text = groupMessageArray[indexPath.row].sent_at
            cell.receivedMessageLabel.text = groupMessageArray[indexPath.row].text
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cellSelection = Int(indexPath.row)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessageArray.count
    }
    
    func getMessages(completed: @escaping() -> ()) {
        //GET messages
        let myUrl = URL(string: "\(base_url)/group-chats/\(currentGroupID)/messages")
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
                self.groupMessageArray = try
                    JSONDecoder().decode([GroupMessage].self, from: data!)
                
                DispatchQueue.main.async {
                    completed()
                }
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem for THIS GET)")
                print(error)
            }
        }
        task.resume()
    }
    
    func sendGroupMessage() {
        //param for creating another message
        let textSend = groupMessageTextField.text
        
        let myUrl = URL(string: "\(base_url)/group-chats/\(currentGroupID)/messages")
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        request.addValue(accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let postMessageString = ["text": textSend!] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postMessageString, options: .prettyPrinted)
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
        }
        task.resume()
        
        DispatchQueue.main.async {
            self.groupMessageTextField.text = ""
        }
        
        getMessages {
            self.groupTableView.reloadData()
        }
    }
    
    //Member leaves a group if exit group button is pressed
    func leaveGroup() {
        //params for leaving a chat
        let titleGroup = chatName
        
        let myURL = URL(string: "\(base_url)/group-chats/\(currentGroupID)/leave")
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
                
                groupDetails.is_member = false
                self.performSegue(withIdentifier: "unwindToGroups", sender: self)
                
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
                print(error)
            }
        }
        task.resume()
    }
    
    //Admin deletes a group if exit group button is pressed
    func deleteGroup() {
        
        let myURL = URL(string: "\(base_url)/group-chats/\(currentGroupID)")
        var request = URLRequest(url:myURL!)
        request.httpMethod = "DELETE"
        request.addValue(accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
       
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
        }
        task.resume()
        
        //Move to previous tab
        self.performSegue(withIdentifier: "unwindToGroups", sender: self)
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
    
    func confirmMessage(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertController = UIAlertController(title: "Exit Group", message: userMessage, preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                    return
                }
                alertController.addAction(cancelAction)
                
                let destroyAction = UIAlertAction(title: "Yes", style: .destructive) { (action:UIAlertAction!) in
                    
                    self.leaveGroup()
                
                }
                alertController.addAction(destroyAction)
                
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
    func deleteConfirmMessage(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertController = UIAlertController(title: "Disband Group?", message: userMessage, preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                    return
                }
                alertController.addAction(cancelAction)
                
                let destroyAction = UIAlertAction(title: "Yes", style: .destructive) { (action:UIAlertAction!) in
                    
                    self.deleteGroup()
                    
                }
                alertController.addAction(destroyAction)
                
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
}
