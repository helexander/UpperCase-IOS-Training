//
//  SearchPrivateMessageViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 18/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit

class SearchPrivateMessageViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchPrivateTableView: UITableView!
    @IBOutlet weak var searchPrivateTextField: UITextField!
    @IBOutlet weak var sideSearchPrivateConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSearchPrivateConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraintSearch: NSLayoutConstraint!
    @IBOutlet weak var settingsViewSearch: UIView!
    
    var privateMessageArray = [PrivateMessage]()
    var privateChatArray = [PrivateChat]()
    
    var privateSearchMenuIsHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topConstraintSearch.constant = -140
        settingsViewSearch.isHidden = true
        settingsViewSearch.layer.cornerRadius = 7
        
        navigationItem.title = "\(chatName)"
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        if(found == true) {
            //GET messages if a conversation already exists
            retrieveSearchPrivateMessages {
                DispatchQueue.main.async {
                    self.searchPrivateTableView.reloadData()
                }                
            }
        } else {
            //POST (Create) a new conversation
            createChat()
        }
        
        searchPrivateTextField.delegate = self
        searchPrivateTableView.delegate = self
        searchPrivateTableView.dataSource = self
        
        searchPrivateTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "messageTableCell")
        searchPrivateTableView.register(UINib(nibName: "ReceivedMessageCell", bundle: nil) , forCellReuseIdentifier: "receivedMessageCell")
        
        configureTableView()
        
        setUpNavigationBarItem()
        
        searchPrivateTableView.keyboardDismissMode = .onDrag
        self.hideKeyboardWhenTappedAround()
        
        searchPrivateTableView.separatorStyle = .none
        
        let tempImageView = UIImageView(image: UIImage(named: "darkBG"))
        tempImageView.frame = self.searchPrivateTableView.frame
        self.searchPrivateTableView.backgroundView = tempImageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendSearchPrivateButtonoTapped(_ sender: UIButton) {
        sendPrivateMessage()
        
    }
    
    @IBAction func clearChatButtonTapped(_ sender: UIButton) {
        //DELETE messages
        clearMessage()
    }
    
    func configureTableView() {
        searchPrivateTableView.rowHeight = UITableViewAutomaticDimension
        searchPrivateTableView.estimatedRowHeight = 75.0
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.3) {
            self.sideSearchPrivateConstraint.constant = 250
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.sideSearchPrivateConstraint.constant = 43
            self.view.layoutIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let urlString = "\(String(describing: privateMessageArray[indexPath.row].sender.avatar))"
        
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
    
    private func setUpNavigationBarItem() {
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(#imageLiteral(resourceName: "Chat Settings"), for: .normal)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        settingsButton.addTarget(self, action: #selector(menuItemState), for: .touchUpInside)
    }
    
    @objc func menuItemState() {
        if privateSearchMenuIsHidden {
            topConstraintSearch.constant = 0
            settingsViewSearch.isHidden = false
        } else {
            topConstraintSearch.constant = -140
            settingsViewSearch.isHidden = true
        }
        
        privateSearchMenuIsHidden = !privateSearchMenuIsHidden
    }
    
    func sendPrivateMessage() {
        //param for creating another message
        let textSend = searchPrivateTextField.text
        
        print("The chat ID is now: \(chatID)")
        
        let myUrl = URL(string: "\(base_url)/private-chats/\(chatID)/messages")
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
            self.searchPrivateTextField.text = ""
        }
        
        retrieveSearchPrivateMessages {
            self.searchPrivateTableView.reloadData()
        }
    }
    
    func retrieveSearchPrivateMessages(completed: @escaping() -> ()) {
        //GET messages
        getChatID()

        let myUrl = URL(string: "\(base_url)/private-chats/\(chatID)/messages")
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
                // Display an Alert dialog with a friendly error message
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem for GET) when trying to obtain a message")
                print(error)
            }
            
        }
        task.resume()
    }
    
    func getChatID() {
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
                self.privateChatArray = try
                    JSONDecoder().decode([PrivateChat].self, from: data!)
                
                print("The current ID is : \(currentID)")
                print("This is the count for private chat array: \(self.privateChatArray.count)")
                
                for x in 0..<self.privateChatArray.count {
                    if(self.privateChatArray[x].host.id == currentID || self.privateChatArray[x].guest.id == currentID) {
                        chatID = self.privateChatArray[x].id
                    }
                }
            
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem for GET) when trying to get CHAT ID")
                print(error)
            }
            
        }
        task.resume()
    }
    
    func createChat() {
        //params for create or get chat
        let firstName = currentFirstName
        let lastName = currentLastName
        let phoneNumber = currentPhoneNum

        let createChatURL = URL(string: "\(base_url)/private-chats/\(String(describing: (currentID)))")
        var createRequest = URLRequest(url:createChatURL!)
        createRequest.httpMethod = "POST"
        createRequest.addValue(accessToken!, forHTTPHeaderField: "Authorization")
        createRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let createChatString = ["first_name": firstName, "last_name": lastName, "phone_number": phoneNumber] as [String: String]

        do {
            createRequest.httpBody = try JSONSerialization.data(withJSONObject: createChatString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong...(create chat httpBody error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: createRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                var chatDetails = try
                    JSONDecoder().decode(PrivateChat.self, from: data!)
                
                chatDetails.guest.id = chatID
                
                print("New chat has been created")
                
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
            }
        }
        task.resume()
    }
    
    func clearMessage() {
        let myUrl = URL(string: "\(base_url)/private-chats/\(chatID)")
        var request = URLRequest(url:myUrl!)
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
                    self.performSegue(withIdentifier: "unwindToSearchContactsList", sender: self)
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }

}
