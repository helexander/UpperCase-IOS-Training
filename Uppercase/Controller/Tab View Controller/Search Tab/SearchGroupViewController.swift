//
//  SearchGroupViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 10/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class SearchGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchGroupTable: UITableView!
    @IBOutlet weak var searchGroupBar: UISearchBar!
    
    var groupArray = [GroupChat]()
    var currentGroupArray = [GroupChat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadGroupChats{
            DispatchQueue.main.async {
                self.searchGroupTable.reloadData()
            }
        }
        
        searchGroupTable.delegate = self
        searchGroupTable.dataSource = self
        searchGroupBar.delegate = self
    
        searchGroupTable.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "groupTableCell")
        
        searchGroupTable.keyboardDismissMode = .onDrag
        self.hideKeyboardWhenTappedAround()
        
        navigationItem.title = "Search Group Contacts"
        let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        configureTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTableView() {
        searchGroupTable.rowHeight = UITableViewAutomaticDimension
        searchGroupTable.estimatedRowHeight = 180.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentGroupArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupTableCell", for: indexPath) as! GroupTableViewCell
        
        cell.groupNameLabel.text = currentGroupArray[indexPath.row].title.capitalized
        cell.groupPictureImage.image = UIImage(named: "Group")
        cell.groupLastUpdatedLabel.text = currentGroupArray[indexPath.row].updated_at
        
        return cell
    }
    
    //Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentGroupArray = groupArray
            searchGroupTable.reloadData()
            return
        }
        
        currentGroupArray = groupArray.filter({ groupContact -> Bool in
            groupContact.title.lowercased().contains(searchText.lowercased())
        })
        searchGroupTable.reloadData()
    }
    
    //Perform transition between pages (group search to group chats)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatName = groupArray[indexPath.row].title
        currentGroupID = groupArray[indexPath.row].id
        getGroupHostID = groupArray[indexPath.row].host.id
        
        //If userIdDetails is a member of that group then display showSearchGroupChat segue else showGroupDetails segue
        if(groupArray[indexPath.row].is_member == true) {
            performSegue(withIdentifier: "showSearchGroupChat", sender: self)
        } else {
            performSegue(withIdentifier: "showGroupDetails", sender: self)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadGroupChats(completed: @escaping() -> ()){
        let myUrl = URL(string: "\(base_url)/group-chats?query=l&include=members")
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
                self.groupArray = try
                    JSONDecoder().decode([GroupChat].self, from: data!)
                self.currentGroupArray = self.groupArray
                
                DispatchQueue.main.async {
                    completed()
                }
                
            } catch {
                // Display an Alert dialog with a friendly error message
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
                    // Code in this block will trigger when OK button tapped.
                    print("Ok button tapped")
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
    @IBAction func unwindToSearchGroup (_ sender: UIStoryboardSegue) {
        print("Return to search group")
    }
}
