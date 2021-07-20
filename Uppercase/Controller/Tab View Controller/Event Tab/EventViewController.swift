//
//  EventViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 04/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var eventTableView: UITableView!

    var events = [Event]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(accessToken != nil && userId != nil) {
            print("Access token: \(accessToken!)")
            print("Current Logged In User ID: \(userId!)")
        }
                
        loadEvents {
            
            DispatchQueue.main.async {
                self.eventTableView.reloadData()
            }
            
        }

        eventTableView.delegate = self
        eventTableView.dataSource = self
        
        //Register EventCell.xib file
        eventTableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "eventTableCell")
        
        configureTableView()
        
    }
    
    func configureTableView() {
        eventTableView.rowHeight = UITableViewAutomaticDimension
        eventTableView.estimatedRowHeight = 300.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventTableCell", for: indexPath) as! EventCellControllerTableViewCell
        
        cell.titleEvent.text = events[indexPath.row].title.capitalized
        cell.dateEvent.text = events[indexPath.row].date.capitalized
        cell.locationEvent.text = events[indexPath.row].location.capitalized
        cell.eventPreview.image = UIImage(named: "logo")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showEventDetail", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EventDetailsController {
            destination.event = events[(eventTableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    func loadEvents(completed: @escaping() -> ()) {        
        let myUrl = URL(string: "\(base_url)/events")
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "GET" // Compose a query string
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
                self.events = try
                    JSONDecoder().decode([Event].self, from: data!)
                
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
    

}


