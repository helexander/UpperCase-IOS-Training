//
//  GroupChatViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 10/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class GroupChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var groupChatSearchBar: UISearchBar!
    
    var groupChatArray = [GroupChat]()
    var currentGroupChatArray = [GroupChat]()
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadGroupChats{
            self.groupTableView.reloadData()
        }
        
        groupTableView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(GroupChatViewController.getNewData), for: .valueChanged)
        
        groupTableView.delegate = self
        groupTableView.dataSource = self
        groupChatSearchBar.delegate = self
        
        groupTableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "groupTableCell")
        
        groupTableView.keyboardDismissMode = .onDrag
        self.hideKeyboardWhenTappedAround()
        
        navigationItem.title = "Group Chats"
    
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        configureGroupTableView()
        
    }

    //Refreshes the table when the user drags the table downwards
    @objc func getNewData() {
        loadGroupChats{
            self.groupTableView.reloadData()
        }
        self.refreshControl.endRefreshing()
    }
    
    func configureGroupTableView() {
        groupTableView.rowHeight = UITableViewAutomaticDimension
        groupTableView.estimatedRowHeight = 180.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentGroupChatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupTableCell", for: indexPath) as! GroupTableViewCell
        
        cell.groupNameLabel.text = currentGroupChatArray[indexPath.row].title.capitalized
        
        //Host's avatar
        let urlString = "\(String(describing: currentGroupChatArray[indexPath.row].host.avatar))"
        
        if urlString == "nil" {
            cell.groupPictureImage.image = UIImage(named: "Group")
        } else {
            let urlString = "\((currentGroupChatArray[indexPath.row].host.avatar)!)"
            let url = URL(string: urlString)
            cell.groupPictureImage.downloadedFrom(url: url!)
        }
        cell.groupLastUpdatedLabel.text = currentGroupChatArray[indexPath.row].updated_at
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatName = self.currentGroupChatArray[indexPath.row].title
        currentGroupID = self.currentGroupChatArray[indexPath.row].id
        getHostID = self.currentGroupChatArray[indexPath.row].host.id
        
        performSegue(withIdentifier: "showGroupChat", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentGroupChatArray = groupChatArray
            groupTableView.reloadData()
            return
        }
        
        currentGroupChatArray = groupChatArray.filter({ groupChatContact -> Bool in
            groupChatContact.title.lowercased().contains(searchText.lowercased())
        })
        groupTableView.reloadData()
    }
    
    func loadGroupChats(completed: @escaping() -> ()) {
        let myUrl = URL(string: "\(base_url)/group-chats?include=members")
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
                self.groupChatArray = try
                    JSONDecoder().decode([GroupChat].self, from: data!)
                
                self.currentGroupChatArray = self.groupChatArray
                
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
    
    @IBAction func unwindToGroupList(_ sender: UIStoryboardSegue) {
        print("Return to group list")
    }
}
