//
//  EventDetailsController.swift
//  Uppercase
//
//  Created by The Techy Hub on 04/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class EventDetailsController: UIViewController {
    
    @IBOutlet weak var attendanceEvent: UILabel!
    @IBOutlet weak var descriptionEvent: UITextView!
    @IBOutlet weak var imageDetailsEvent: UIImageView!
    
    @IBOutlet weak var titleDetailsEvent: UILabel!
    @IBOutlet weak var dateDetailsEvent: UILabel!
    @IBOutlet weak var locationDetailsEvent: UILabel!

    @IBOutlet weak var attendanceStateButton: UIButton!
    
    var event : Event?
    var eventDet : EventDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadEvents()
        
    }

    @IBAction func attendanceButtonTapped(_ sender: Any) {
        updateAttendance()
    }
    
    func updateAttendance() {
        if(goingState == true) {
            //Change state to false after attendance button has been clicked
            goingState = false
            
        } else if (goingState == false) {
            //Change state to true after attendance button has been clicked
            goingState = true
        }
        
        if let eventID = event?.id {
            let myUrl = URL(string: "\(base_url)/events/\(String(describing: (eventID)))/rsvp")
            var request = URLRequest(url:myUrl!)
            request.httpMethod = "POST"
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
                    var attendanceDetails = try
                        JSONDecoder().decode(EventDetails.self, from: data!)
                    
                    if(goingState == true) {
                        attendanceDetails.is_going = true
                        
                    } else if(goingState == false) {
                        attendanceDetails.is_going = false
                    
                    }
                    
                    DispatchQueue.main.async {
                        self.attendanceEvent.text = "\(String(describing: (attendanceDetails.rsvp_count))) people are going"
                        
                        if(goingState == true){
                            self.attendanceStateButton.backgroundColor = UIColor.green
                            self.attendanceStateButton.setTitle("I am going!", for: .normal)
                            self.attendanceStateButton.setTitleColor(UIColor.black, for: .normal)
                        } else if(goingState == false) {
                            self.attendanceStateButton.backgroundColor = UIColor.red
                            self.attendanceStateButton.setTitle("I am NOT going!", for: .normal)
                            self.attendanceStateButton.setTitleColor(UIColor.white, for: .normal)
                        }
                    }
                    
                } catch {
                    self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
                    print(error)
                }
                
            }
            task.resume()
        }
    }
    
    func loadEvents() {
        if let eventID = event?.id {
            let myUrl = URL(string: "\(base_url)/events/\(String(describing: (eventID)))")
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
                    let eventDetails = try
                        JSONDecoder().decode(EventDetails.self, from: data!)
                    DispatchQueue.main.async {
                        let urlString = "\(String(describing: eventDetails.cover))"
                        
                        if urlString == "nil" {
                            self.imageDetailsEvent.image = UIImage(named: "logo")
                        } else {
                            let urlString = "\((eventDetails.cover)!)"
                            let url = URL(string: urlString)
                            self.imageDetailsEvent.downloadedFrom(url: url!)
                        }
                        
                        self.titleDetailsEvent.text = eventDetails.title
                        self.dateDetailsEvent.text = eventDetails.date
                        self.locationDetailsEvent.text = eventDetails.location
                        self.attendanceEvent.text = "\(String(describing: (eventDetails.rsvp_count))) people are going"
                        self.descriptionEvent.text = eventDetails.description
                        if(eventDetails.is_going == true) {
                            goingState = true
                            self.attendanceStateButton.backgroundColor = UIColor.green
                            self.attendanceStateButton.setTitle("I am going!", for: .normal)
                            self.attendanceStateButton.setTitleColor(UIColor.black, for: .normal)
                        } else {
                            goingState = false
                            self.attendanceStateButton.backgroundColor = UIColor.red
                            self.attendanceStateButton.setTitle("I am NOT going!", for: .normal)
                            self.attendanceStateButton.setTitleColor(UIColor.white, for: .normal)
                        }
                    }
                } catch {
                    self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
                    print(error)
                }
                
            }
            task.resume()
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
}
