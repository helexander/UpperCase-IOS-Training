//
//  ChatMessagesViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 11/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ChatMessagesViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var privateMessage : PrivateChat?
    
    var privateMessageArray = [PrivateMessage]()
    
    @IBOutlet weak var chatMessageTable: UITableView!
    @IBOutlet weak var messageContentTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var privateSettingsView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var privateMenuIsHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topConstraint.constant = -140
        privateSettingsView.isHidden = true
        privateSettingsView.layer.cornerRadius = 7
        
        retrieveMessages {
            
            DispatchQueue.main.async {
                self.chatMessageTable.reloadData()
            }
            
        }
        
        messageContentTextField.delegate = self
        chatMessageTable.delegate = self
        chatMessageTable.dataSource = self
        
        chatMessageTable.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "messageTableCell")
        chatMessageTable.register(UINib(nibName: "ReceivedMessageCell", bundle: nil) , forCellReuseIdentifier: "receivedMessageCell")

        navigationItem.title = "\(chatName)"
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        setUpNavigationBarItem()
        
        configureTableView()
        
        //Suppose to make the view of the table to the bottom once the page loads
//        let lastRow: Int = self.chatMessageTable.numberOfRows(inSection: 0) - 1
//        let indexPath = IndexPath(row: lastRow, section: 0);
//        self.chatMessageTable.scrollToRow(at: indexPath, at: .top, animated: false)
        
        chatMessageTable.keyboardDismissMode = .onDrag
        self.hideKeyboardWhenTappedAround()
        
        chatMessageTable.separatorStyle = .none
        
        //Sets the background image of the chats
        let tempImageView = UIImageView(image: UIImage(named: "darkBG"))
        tempImageView.frame = self.chatMessageTable.frame
        self.chatMessageTable.backgroundView = tempImageView
    }
    
    @IBAction func sendMessageButtonTapped(_ sender: UIButton) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sendMessage))
        
        view.addGestureRecognizer(tap)
        
        sendMessage()
    }
    
    @IBAction func clearChatButtonTapped(_ sender: UIButton) {
        deleteMessage()
    }
    
    func configureTableView() {
        chatMessageTable.rowHeight = UITableViewAutomaticDimension
        chatMessageTable.estimatedRowHeight = 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let urlString = "\(String(describing: privateMessageArray[indexPath.row].sender.avatar))"
        
        //Assign separate custom cells along with customized background for the received and sent out messages
        if(privateMessageArray[indexPath.row].sender.id == Int(userIdDetails)) {
            //Sent out messages
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableCell", for: indexPath) as! MessageTableViewCell
            
            cell.messageView.backgroundColor = UIColor.yellow
            
            if urlString == "nil" {
                cell.messageImage.image = UIImage(named: "Hat")
            } else {
                let urlString = "\((privateMessageArray[indexPath.row].sender.avatar)!)"
                let url = URL(string: urlString)
                cell.messageImage.downloadedFrom(url: url!)
            }
            cell.messageImage.layer.cornerRadius = cell.messageImage.frame.size.width/2
            cell.messageImage.clipsToBounds = true
            
            cell.timeChat.text = privateMessageArray[indexPath.row].sent_at
            cell.messageTextLabel.text = privateMessageArray[indexPath.row].text
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
                let urlString = "\((privateMessageArray[indexPath.row].sender.avatar)!)"
                let url = URL(string: urlString)
                cell.receivedMessageImage.downloadedFrom(url: url!)
            }
            cell.receivedMessageImage.layer.cornerRadius = cell.receivedMessageImage.frame.size.width/2
            cell.receivedMessageImage.clipsToBounds = true
            
            cell.receivedTimeLabel.text = privateMessageArray[indexPath.row].sent_at
            cell.receivedMessageLabel.text = privateMessageArray[indexPath.row].text
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cellSelection = Int(indexPath.row)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return privateMessageArray.count
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.3) {
            self.heightConstraint.constant = 250
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.heightConstraint.constant = 43
            self.view.layoutIfNeeded()
        }
    }
    
    //Navigation bar item at the top right part of the navigation bar
    private func setUpNavigationBarItem() {
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(#imageLiteral(resourceName: "Chat Settings"), for: .normal)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        settingsButton.addTarget(self, action: #selector(menuItemState), for: .touchUpInside)
    }
    
    @objc func menuItemState() {
        if privateMenuIsHidden {
            topConstraint.constant = 0
            privateSettingsView.isHidden = false
            print("open menu bar")
            
        } else {
            topConstraint.constant = -140
            privateSettingsView.isHidden = true
            print("close menu bar")
        }
        privateMenuIsHidden = !privateMenuIsHidden
    }
    
    func retrieveMessages(completed: @escaping() -> ()) {
        //GET messages
        let myUrl = URL(string: "\(base_url)/private-chats/\(currentID)/messages")
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
                self.privateMessageArray = try
                    JSONDecoder().decode([PrivateMessage].self, from: data!)

                DispatchQueue.main.async {
                    completed()
                }
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem for GET)")
                print(error)
            }

        }
        task.resume()
        
    }
    
    func deleteMessage() {
        //DELETE messages
        let myUrl = URL(string: "\(base_url)/private-chats/\(currentID)")
        var request = URLRequest(url:myUrl!)
        print(request)
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
        
        DispatchQueue.main.async {
            self.successfulMessage(userMessage: "Messages were successfully deleted!")
        }
    }
    
    @objc func sendMessage() {
        //param for creating another message
        let textSend = messageContentTextField.text
        
        let myUrl = URL(string: "\(base_url)/private-chats/\(currentID)/messages")
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
            //When the user clicks on the send message button, the table would reload, displaying the new data obtained from the database
            self.retrieveMessages {
                self.chatMessageTable.reloadData()
            }
            
            self.messageContentTextField.text = ""            
        }
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
    
    func successfulMessage(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertController = UIAlertController(title: "Cleared", message: userMessage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }

    
}
