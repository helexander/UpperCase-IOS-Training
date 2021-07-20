//
//  SearchGroupMessageViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 18/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class SearchGroupMessageViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchGroupTableView: UITableView!
    @IBOutlet weak var searchGroupTextField: UITextField!
    @IBOutlet weak var sideSearchGroupConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSearchGroupConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraintSearchGroup: NSLayoutConstraint!
    @IBOutlet weak var settingsViewSearchGroup: UIView!
    
    var searchGroupMessageArray = [GroupMessage]()
    
    var settingsMenuIsHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topConstraintSearchGroup.constant = -140
        settingsViewSearchGroup.isHidden = true
        settingsViewSearchGroup.layer.cornerRadius = 7
        
        getGroupMessage {
            DispatchQueue.main.async {
                self.searchGroupTableView.reloadData()
            }
        }
        
        searchGroupTextField.delegate = self
        searchGroupTableView.delegate = self
        searchGroupTableView.dataSource = self
        
        searchGroupTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "messageTableCell")
        searchGroupTableView.register(UINib(nibName: "ReceivedMessageCell", bundle: nil) , forCellReuseIdentifier: "receivedMessageCell")
        
        navigationItem.title = "\(chatName)"
        
        setUpNavigationBarItem()
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        configureTableView()
        
        searchGroupTableView.keyboardDismissMode = .onDrag
        self.hideKeyboardWhenTappedAround()
        
        searchGroupTableView.separatorStyle = .none
        
        let tempImageView = UIImageView(image: UIImage(named: "darkBG"))
        tempImageView.frame = self.searchGroupTableView.frame
        self.searchGroupTableView.backgroundView = tempImageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sendSearchGroupButtonTapped(_ sender: UIButton) {
        sendGroupMessages()

    }
    
    @IBAction func editGroupButtonTapped(_ sender: UIButton) {
    
    }
    
    @IBAction func exitGroupButtonTapped(_ sender: UIButton) {
        if(getGroupHostID == Int(userIdDetails)) {
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
            topConstraintSearchGroup.constant = 0
            settingsViewSearchGroup.isHidden = false
        } else {
            topConstraintSearchGroup.constant = -140
            settingsViewSearchGroup.isHidden = true
        }
        settingsMenuIsHidden = !settingsMenuIsHidden
    }
    
    func configureTableView() {
        searchGroupTableView.rowHeight = UITableViewAutomaticDimension
        searchGroupTableView.estimatedRowHeight = 75.0
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.3) {
            self.sideSearchGroupConstraint.constant = 250
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.sideSearchGroupConstraint.constant = 43
            self.view.layoutIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let urlString = "\(String(describing: searchGroupMessageArray[indexPath.row].sender.avatar))"
        
        if(searchGroupMessageArray[indexPath.row].sender.id == Int(userIdDetails)) {
            //Sent out message
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableCell", for: indexPath) as! MessageTableViewCell
            
            cell.messageView.backgroundColor = UIColor.yellow
            
            if urlString == "nil" {
                cell.messageImage.image = UIImage(named: "Hat")
            } else {
                let urlString = "\((searchGroupMessageArray[indexPath.row].sender.avatar)!)"
                let url = URL(string: urlString)
                cell.messageImage.downloadedFrom(url: url!)
            }
            
            cell.timeChat.text = searchGroupMessageArray[indexPath.row].sent_at
            cell.messageTextLabel.text = searchGroupMessageArray[indexPath.row].text
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cellSelection = Int(indexPath.row)
            
            return cell
            
        } else {
            //Recieved message
            let cell = tableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! ReceivedMessageTableViewCell
            
            cell.receivedView.backgroundColor = UIColor.lightGray
            
            if urlString == "nil" {
                cell.receivedMessageImage.image = UIImage(named: "Hat")
            } else {
                let urlString = "\((searchGroupMessageArray[indexPath.row].sender.avatar)!)"
                let url = URL(string: urlString)
                cell.receivedMessageImage.downloadedFrom(url: url!)
            }
            
            cell.receivedTimeLabel.text = searchGroupMessageArray[indexPath.row].sent_at
            cell.receivedMessageLabel.text = searchGroupMessageArray[indexPath.row].text
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cellSelection = Int(indexPath.row)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchGroupMessageArray.count
    }
    
    func getGroupMessage(completed: @escaping() -> ()) {
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
                self.searchGroupMessageArray = try
                    JSONDecoder().decode([GroupMessage].self, from: data!)
                
                DispatchQueue.main.async {
                    completed()
                }
            } catch {
                // Display an Alert dialog with a friendly error message
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem for GET)")
                print(error)
            }
            
        }
        task.resume()
    }
    
    func sendGroupMessages() {
        //param for creating another message
        let textSend = searchGroupTextField.text
        
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
            self.searchGroupTextField.text = ""
        }
        
        getGroupMessage {
            self.searchGroupTableView.reloadData()
        }
    }
    
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
                self.performSegue(withIdentifier: "unwindToSearchGroups", sender: self)
                
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
                print(error)
            }
        }
        task.resume()
    }
    
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
        
        self.performSegue(withIdentifier: "unwindToSearchGroups", sender: self)
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
