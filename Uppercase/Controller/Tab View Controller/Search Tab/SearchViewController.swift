//
//  SearchViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 04/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sideMenuSearchConstraint: NSLayoutConstraint!
    
    var contactArray = [Member]()
    var currentContactArray = [Member]()
    var isSlideMenuSearchHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContacts {
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
            
        }
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchBar.delegate = self
        
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        configureTableView()
        searchTableView.keyboardDismissMode = .onDrag
        
        sideMenuSearchConstraint.constant = -140
        self.hideKeyboardWhenTappedAround()
        
    }
    
    @IBAction func organizeSearchButtonTapped(_ sender: UIBarButtonItem) {
    
        if isSlideMenuSearchHidden {
            sideMenuSearchConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            sideMenuSearchConstraint.constant = -140
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        isSlideMenuSearchHidden = !isSlideMenuSearchHidden
        
    }
    
    func configureTableView() {
        searchTableView.rowHeight = UITableViewAutomaticDimension
        searchTableView.estimatedRowHeight = 90.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentContactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell") as? TableCell else {
            return UITableViewCell()
        }
        
        let urlString = "\(String(describing: currentContactArray[indexPath.row].avatar))"
        if urlString == "nil" {
            cell.imageProfile.image = UIImage(named: "profile_icon")
            
        } else {
            let urlString = "\((currentContactArray[indexPath.row].avatar)!)"
            let url = URL(string: urlString)
            cell.imageProfile.downloadedFrom(url: url!)
        }
        
        
        
        cell.nameProfileLabel.text = currentContactArray[indexPath.row].first_name.capitalized
        return cell
    }    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showContactDetails", sender: self)
        
        sideMenuSearchConstraint.constant = -140
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationPath = segue.destination as? ContactDetailsController {
            destinationPath.contacts = currentContactArray[(searchTableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    //Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentContactArray = contactArray
            searchTableView.reloadData()
            return
        }
        
        currentContactArray = contactArray.filter({ contact -> Bool in
            contact.first_name.lowercased().contains(searchText.lowercased())
        })
        searchTableView.reloadData()
    }
    
    func loadContacts(completed: @escaping() -> ()) {        

        let myUrl = URL(string: "\(base_url)/members")
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
                self.contactArray = try
                    JSONDecoder().decode([Member].self, from: data!)
                self.currentContactArray = self.contactArray
                
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
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
    @IBAction func unwindToSearchContacts(_ sender: UIStoryboardSegue) {
        print("Return to search contacts list")
    }
    
}
