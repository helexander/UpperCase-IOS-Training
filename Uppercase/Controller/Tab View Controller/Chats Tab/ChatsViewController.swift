//
//  ChatsViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 10/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var privateChatSearchBar: UISearchBar!
    @IBOutlet weak var privateChatsTableView: UITableView!
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    var privateChatArray = [PrivateChat]()
    var currentPrivateChatArray = [PrivateChat]()

    var refreshControl = UIRefreshControl()
    
    var isSlideMenuHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuConstraint.constant = -140
        privateChatsTableView.keyboardDismissMode = .onDrag
        self.hideKeyboardWhenTappedAround()
        
        loadPrivateChats{
            DispatchQueue.main.async {
                self.privateChatsTableView.reloadData()
            }            
        }
        
        privateChatsTableView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(ChatsViewController.getNewData), for: .valueChanged)
        
        privateChatsTableView.delegate = self
        privateChatsTableView.dataSource = self
        privateChatSearchBar.delegate = self
        
    }
    
    //The navigation bar item at the top right corner
    @IBAction func organizeButtonTapped(_ sender: UIBarButtonItem) {
        
        if isSlideMenuHidden {
            sideMenuConstraint.constant = 0
            
            //Animations on menu
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
        } else {
            sideMenuConstraint.constant = -140
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        isSlideMenuHidden = !isSlideMenuHidden
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentPrivateChatArray.count
    }
    
    //Drags the table down to refresh the entire table
    @objc func getNewData() {
        loadPrivateChats{
            self.privateChatsTableView.reloadData()
        }
        self.refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateChatCell") as? ChatsTableViewCell else {
            return UITableViewCell()
        }
        
        //Displays a contact if the logged in user is the host of a chat
        if(currentPrivateChatArray[indexPath.row].host.id == Int(userIdDetails))
        {
            let urlString = "\(String(describing: currentPrivateChatArray[indexPath.row].guest.avatar))"
            
            if urlString == "nil" {
                cell.imageProfileChats.image = UIImage(named: "Contact2")
            } else {
                let urlString = "\((currentPrivateChatArray[indexPath.row].guest.avatar)!)"
                let url = URL(string: urlString)
                cell.imageProfileChats.downloadedFrom(url: url!)
            }
            
            cell.nameChats.text = currentPrivateChatArray[indexPath.row].guest.first_name.capitalized
            cell.timeChatsLabel.text = currentPrivateChatArray[indexPath.row].updated_at
            
        }
        //Displays a contact if the logged in user is the guest of a chat
        else if (currentPrivateChatArray[indexPath.row].guest.id == Int(userIdDetails))
        {
            let urlString = "\(String(describing: currentPrivateChatArray[indexPath.row].host.avatar))"
            
            if urlString == "nil" {
                cell.imageProfileChats.image = UIImage(named: "Contact1")
            } else {
                print("Contains a value!")
                let urlString = "\((currentPrivateChatArray[indexPath.row].host.avatar)!)"
                let url = URL(string: urlString)
                //print(url!)
                cell.imageProfileChats.downloadedFrom(url: url!)
            }
            
            cell.nameChats.text = currentPrivateChatArray[indexPath.row].host.first_name.capitalized
            cell.timeChatsLabel.text = currentPrivateChatArray[indexPath.row].updated_at
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //As it moves onto the next segue, the host/guest's name and ID will be assigned to a globally declared variable to be used in the next tab
        if(self.privateChatArray[indexPath.row].host.id == Int(userIdDetails)) {
            chatName = "\(self.privateChatArray[indexPath.row].guest.first_name) \(self.privateChatArray[indexPath.row].guest.last_name)"
            currentID = privateChatArray[indexPath.row].id
        }
        else if(self.privateChatArray[indexPath.row].guest.id == Int(userIdDetails)) {
            chatName = "\(self.privateChatArray[indexPath.row].host.first_name) \(self.privateChatArray[indexPath.row].host.last_name)"
            currentID = privateChatArray[indexPath.row].id
        }
        
        performSegue(withIdentifier: "showPrivateChat", sender: self)
        
        //Makes the side menu move away after the page has been navigated away
        sideMenuConstraint.constant = -140
        privateChatsTableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChatMessagesViewController {
            destination.privateMessage = privateChatArray[(privateChatsTableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    //Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentPrivateChatArray = privateChatArray
            privateChatsTableView.reloadData()
            return
        }
        
        currentPrivateChatArray = privateChatArray.filter({ privateContact -> Bool in
            privateContact.host.first_name.lowercased().contains(searchText.lowercased()) || privateContact.guest.first_name.lowercased().contains(searchText.lowercased())
        })
        
        privateChatsTableView.reloadData()
    }
    
    func loadPrivateChats(completed: @escaping() -> ()) {
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
                self.currentPrivateChatArray = self.privateChatArray
                
                DispatchQueue.main.async {
                    completed()
                }
            } catch {
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
                    //Goes to the previous tab
                    self.performSegue(withIdentifier: "unwindToContactList", sender: self)
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
    @IBAction func unwindToContacts (_ sender: UIStoryboardSegue) {
        print("Return to contact list")
    }
}
