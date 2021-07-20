//
//  SignInViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 03/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class SignInViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(accessToken != nil && userId != nil) {
            print("Access token: \(accessToken!)")
            print("Current Logged In User ID: \(userId!)")
        }
        
        signInButton.layer.cornerRadius = 7
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        print("This is the sign in button")
        
        let userName = userNameTextField.text
        let userPassword = passwordTextField.text
    
        // Check if required fields are not empty
        if (userName?.isEmpty)! || (userPassword?.isEmpty)!
        {
            print("User name \(String(describing: userName)) or password \(String(describing: userPassword)) is empty")
            displayMessage(userMessage: "One of the required fields is missing")
            
            return
        }
        
        //Send HTTP Request to perform Sign In
        requestHTTP(userName: userName!, userPassword: userPassword!)
        
    }
    
    func requestHTTP(userName: String, userPassword: String) {
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        activityIndicator()
        
        let myUrl = URL(string: "\(base_url)/login")
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"// Compose a query string
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["email": userName, "password": userPassword] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong...")
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else { return }
            
            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
            
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
            
            //Let's convert response sent from a server side code to a NSDictionary object:
            do {
                
                let uppercase = try JSONDecoder().decode(UppercaseResponse.self, from: data)
                print(uppercase.token, uppercase.current_member.id)
                
                accessToken = uppercase.token
                let userId = String(describing: uppercase.current_member.id)
                print("User ID: \(userId)")
                
                userIdDetails = userId
                
                if (accessToken?.isEmpty)!
                {
                    // Display an Alert dialog with a friendly error message
                    self.displayMessage(userMessage: "Could not successfully perform this request because there is no access token. Please try again later")
                    return
                }
                
                let saveAccesssToken: Bool = KeychainWrapper.standard.set(accessToken!, forKey: "accessToken")
                let saveUserId: Bool = KeychainWrapper.standard.set(userId, forKey: "userId")
                
                print("Access Token:\(saveAccesssToken)")
                print("User ID: \(saveUserId)")
                
                DispatchQueue.main.async
                    {
                        let homePage = self.storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
                        let appDelegate = UIApplication.shared.delegate
                        appDelegate?.window??.rootViewController = homePage
                }
                
            } catch let error {
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
    
    //Loading indicator
    func activityIndicator() {
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        // Position Activity Indicator in the center of the main view
        myActivityIndicator.center = view.center
        
        // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
        myActivityIndicator.hidesWhenStopped = false
        
        // Start Activity Indicator
        myActivityIndicator.startAnimating()
        
        view.addSubview(myActivityIndicator)
    }
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView)
    {
        DispatchQueue.main.async
            {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
        }
    }
    
}

