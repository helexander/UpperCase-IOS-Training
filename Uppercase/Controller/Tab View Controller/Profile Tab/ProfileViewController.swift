//
//  ProfileViewController.swift
//  Uppercase
//
//  Created by The Techy Hub on 04/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var firstNameProfileTextField: UITextField!
    @IBOutlet weak var lastNameProfileTextField: UITextField!
    @IBOutlet weak var emailProfileTextField: UITextField!
    @IBOutlet weak var phoneNumberProfileTextField: UITextField!
    @IBOutlet weak var joinedAppProfileTextField: UITextField!
    @IBOutlet weak var companyDetailsProfileTextField: UITextField!
    @IBOutlet weak var positionCompanyProfileTextField: UITextField!
    @IBOutlet weak var joinedCompanyProfileTextField: UITextField!
    @IBOutlet weak var leftCompanyProfileTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var event : Event?
    var user : UppercaseResponse?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 7
        
        loadUserDetails()
        
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "userId")
        
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = loginPage
        
    }
    
    @IBAction func saveChangesProfileButtonTapped(_ sender: UIButton) {
    
        // Check if required fields are not empty
        let firstNameProfile = firstNameProfileTextField.text
        let lastNameProfile = lastNameProfileTextField.text
        let phoneNumberProfile = phoneNumberProfileTextField.text
        let companyDetailsProfile = companyDetailsProfileTextField.text
        let positionCompanyProfile = positionCompanyProfileTextField.text
        let joinedCompanyProfile = joinedAppProfileTextField.text
        let leftCompanyProfile = leftCompanyProfileTextField.text
        
        if (firstNameProfile?.isEmpty)! || (lastNameProfile?.isEmpty)! || (phoneNumberProfile?.isEmpty)! || (companyDetailsProfile?.isEmpty)! || (positionCompanyProfile?.isEmpty)! || (joinedCompanyProfile?.isEmpty)! || (leftCompanyProfile?.isEmpty)!
        {
            displayMessage(userMessage: "One of the required fields is missing")
            
            return
        }
        
        //POST changes to database
        saveUpdate()
    }
    
    func loadUserDetails() {
        let userID = userIdDetails
        let myUrl = URL(string: "\(base_url)/members/\(String(describing: (userID)))")
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
                let userDetails = try
                    JSONDecoder().decode(MemberDetails.self, from: data!)
                let urlString = "\(String(describing: userDetails.avatar))"
                
                DispatchQueue.main.async {
                    if urlString == "nil" {
                        self.imageProfile.image = UIImage(named: "profile_icon")
                    } else {
                        let urlString = "\((userDetails.avatar)!)"
                        let url = URL(string: urlString)
                        self.imageProfile.downloadedFrom(url: url!)
                    }
                    self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width/2
                    self.imageProfile.clipsToBounds = true
                    self.firstNameProfileTextField.text = "\(userDetails.first_name)"
                    self.lastNameProfileTextField.text = "\(userDetails.last_name)"
                    self.emailProfileTextField.text = "\(userDetails.email)"
                    self.emailProfileTextField.textColor = UIColor.gray
                    self.phoneNumberProfileTextField.text = "\(userDetails.phone_number)"
                    self.joinedAppProfileTextField.text = "\(userDetails.join_date)"
                    self.joinedAppProfileTextField.textColor = UIColor.gray
                    self.companyDetailsProfileTextField.text = "\(userDetails.company.name)"
                    self.positionCompanyProfileTextField.text = "\(userDetails.company.position)"
                    self.joinedCompanyProfileTextField.text = "\(userDetails.company.join_date)"
                    self.leftCompanyProfileTextField.text = "\(userDetails.company.leave_date)"
                }
                
                
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
                print(error)
            }
            
        }
        task.resume()
    }
    
    func saveUpdate() {
        changeContactInfo()
        
        changeCompanyDetails()
        
        changePassword()
        
        self.displayMessage(userMessage: "Successfully saved information!")
    }
    
    func changeContactInfo() {
        //params for member settings
        let firstName = firstNameProfileTextField.text
        let lastName = lastNameProfileTextField.text
        let phoneNumber = phoneNumberProfileTextField.text
        
        
        //access edit member settings
        let settingsURL = URL(string: "\(base_url)/members/settings")
        var settingRequest = URLRequest(url:settingsURL!)
        settingRequest.httpMethod = "PATCH"
        settingRequest.addValue(accessToken!, forHTTPHeaderField: "Authorization")
        settingRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let patchString = ["first_name": firstName!, "last_name": lastName!, "phone_number": phoneNumber!] as [String: String]
        
        do {
            settingRequest.httpBody = try JSONSerialization.data(withJSONObject: patchString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong...(member setting httpBody error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: settingRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                var userDetails = try
                    JSONDecoder().decode(MemberDetails.self, from: data!)
                
                DispatchQueue.main.async {
                    //Assigning values to individual values in database
                    userDetails.first_name = self.firstNameProfileTextField.text!
                    userDetails.last_name = self.lastNameProfileTextField.text!
                    userDetails.email = self.emailProfileTextField.text!
                    userDetails.phone_number = self.phoneNumberProfileTextField.text!
                    userDetails.join_date = self.joinedAppProfileTextField.text!
                }
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
                print(error)
            }
        }
        task.resume()
    }
    
    func changeCompanyDetails() {
        //param for company store
        let companyName = companyDetailsProfileTextField.text
        let companyPosition = positionCompanyProfileTextField.text
        let companyJoinDate = joinedCompanyProfileTextField.text
        
        //access edit company settings
        let companySettingsURL = URL(string: "\(base_url)/members/company")
        var companySettingRequest = URLRequest(url:companySettingsURL!)
        companySettingRequest.httpMethod = "PATCH"
        companySettingRequest.addValue(accessToken!, forHTTPHeaderField: "Authorization")
        companySettingRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let patchCompanyString = ["name": companyName!, "position": companyPosition!, "join_date": companyJoinDate!] as [String: String]
        
        do {
            companySettingRequest.httpBody = try JSONSerialization.data(withJSONObject: patchCompanyString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong...(company setting httpBody error)")
            return
        }
        
        let task_company = URLSession.shared.dataTask(with: companySettingRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                companySettingRequest.httpBody = try JSONSerialization.data(withJSONObject: patchCompanyString, options: .prettyPrinted)
                
                var companyDetails = try
                    JSONDecoder().decode(MemberDetails.self, from: data!)
                
                DispatchQueue.main.async {
                    //Assigning values to individual values in database
                    companyDetails.company.name = self.companyDetailsProfileTextField.text!
                    companyDetails.company.position = self.positionCompanyProfileTextField.text!
                    companyDetails.company.join_date = self.joinedCompanyProfileTextField.text!
                    companyDetails.company.leave_date = self.leftCompanyProfileTextField.text!
                }
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (decoding problem)")
                print(error)
            }
        }
        task_company.resume()
    }
    
    /* This function is still not working, does not change the existing password */
    func changePassword() {
        //params for changing a new password
        let currentUserPassword = currentPasswordTextField.text
        let newUserPassword = newPasswordTextField.text
        let confirmNewPassword = confirmPasswordTextField.text
        
        //access edit member password settings
        let settingsURL = URL(string: "\(base_url)/members/change-password")
        var settingRequest = URLRequest(url:settingsURL!)
        settingRequest.httpMethod = "PATCH"
        settingRequest.addValue(accessToken!, forHTTPHeaderField: "Authorization")
        settingRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let patchString = ["current_password": currentUserPassword!, "password": newUserPassword!, "password_confirmation": confirmNewPassword!] as [String: String]
        
        do {
            settingRequest.httpBody = try JSONSerialization.data(withJSONObject: patchString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong...(password setting httpBody error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: settingRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                var changePW = try
                    JSONDecoder().decode(PasswordDetail.self, from: data!)
                
                print("The current password is: \(changePW.current_password)")
                
                if(currentUserPassword != changePW.current_password) {
                    self.displayMessage(userMessage: "The entered password does not match the current password")
                    
                } else {
                    changePW.current_password = self.currentPasswordTextField.text!
                    changePW.password = self.newPasswordTextField.text!
                    changePW.password_confirmation = self.confirmPasswordTextField.text!
                }
                
                DispatchQueue.main.async {
                    self.currentPasswordTextField.text = ""
                    self.newPasswordTextField.text = ""
                    self.confirmPasswordTextField.text = ""
                    
                }
                
            } catch {
                // Display an Alert dialog with a friendly error message
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later (password decoding problem)")
            }
        }
        task.resume()
    }
    
    /* Image picker */ /* !Function below still doesn't work! */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageSelect = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageProfile.image = imageSelect
        imageProfile.contentMode = .scaleAspectFit
        imageProfile.layer.cornerRadius = 10
        imageProfile.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
        
    }
    
    /* Image picker ends */
    
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
