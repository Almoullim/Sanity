//
//  ViewController.swift
//  MP Project
//
//  Created by Ali on 3/29/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

// The viewController used for Authintaction actions such as 'register' and 'login'
class RegisterViewController: UIViewController {
    
    // Google Firestore connection
    var db: Firestore!
    
    // Register object
    @IBOutlet weak var registerName: UITextField!
    @IBOutlet weak var registerUsername: UITextField!
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    @IBOutlet weak var registerPhone: UITextField!
    @IBOutlet weak var genderControl: UISegmentedControl!
    var userType = ""
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var registerActivity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change UITextField's placeholder color
        registerName.attributedPlaceholder = NSAttributedString(string: "Full Name..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        registerUsername.attributedPlaceholder = NSAttributedString(string: "Username..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        registerEmail.attributedPlaceholder = NSAttributedString(string: "Email..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        registerPassword.attributedPlaceholder = NSAttributedString(string: "Password..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        registerPhone.attributedPlaceholder = NSAttributedString(string: "Phone..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.hideKeyboardWhenTappedAround()
        // [END setup]
        
        // Observ the keyboard actions and call the specified methods
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /*
     Move the 'view' up by the size of the keyboard minus 150pt
     so the keyboard won't cover all the UITextField's
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 150
            }
        }
    }
    
    // Reset the 'view' origin points to default after the keyboard hides
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // Set the stuatus bar content to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
         if navigating to the login view using the LoginView segue identifier
         which is called once the registration process is finished -> set the username
         field on the login screen to the one used to sign up for 'ease of access'
         */
        if segue.identifier == "LoginView" {
            let nav = segue.destination as? UINavigationController
            let view = nav?.viewControllers.first as? LoginViewController
            view?.username = self.registerUsername.text!
        }
    }
    
    @IBAction func helpSeekerRegisterClicked(_ sender: UIButton) {
        // Create an alert for a failed register/empty field
        let alert = UIAlertController(title: "Wrong Username/Password", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        
        // Make sure the register fields are not empty
        if     self.registerUsername.text?.isEmpty == true
            || self.registerPassword.text?.isEmpty == true
            || self.registerName.text?.isEmpty == true
            || self.registerEmail.text?.isEmpty == true
            || self.registerPhone.text?.isEmpty == true
        {
            alert.title = "Please fill all the fields"
            self.present(alert, animated: true)
            return
        }
        
        // Set the button to 'empty' when the its disabled
        registerBtn.setTitle("", for: .disabled)
        
        // Show the activityIndicator and disable the button
        registerActivity.startAnimating()
        registerBtn.isEnabled = false
        
        // Create a new [Auth] user (Help Seeker) with the provided details
        Auth.auth().createUser(withEmail: registerEmail.text!, password: registerPassword.text!) { authResult, error in
            
            if let error = error {
                print("Error creating user in Firebase/Auth: \(error)")
                
                alert.title = "Registration Error"
                alert.message = "An error occured while registering, please contact support. ErrorCode: 111"
                self.present(alert, animated: true)
            } else {
                print("User created in Firebase/Auth")
            }
            
            // Create a new [Document] user with all of its details in 'users' collection
            self.db
                .collection("users")
                .document(self.registerUsername.text!)
                .setData([
                    "uid": Auth.auth().currentUser?.uid as Any,
                    "isAcrive": true,
                    "name": self.registerName.text!,
                    "email": self.registerEmail.text!,
                    "phone": self.registerPhone.text!,
                    "username": self.registerUsername.text!,
                    "userType": self.userType,
                    "gender": self.genderControl.selectedSegmentIndex == 0 ? "m" : "f",
                    "created_at": Timestamp.init()
                ]) { err in
                    
                    // Hide activity indicator and reanable the button
                    self.registerActivity.stopAnimating()
                    self.registerBtn.isEnabled = true
                    
                    if let err = err {
                        print("Error creating user in Firebase/Firestore: \(err)")
                        
                        alert.title = "Registration Error"
                        alert.message = "An error occured while registering, please contact support. ErrorCode: 121"
                        self.present(alert, animated: true)
                    } else {
                        print("User created in Firebase/Firestore")
                    }
            }
            // Send verification to the user email address
            Auth.auth().currentUser?.sendEmailVerification { (error) in
                if let _ = error {
                    alert.title = "Registration Error"
                    alert.message = "An error occured while sending verification email, please contact support. ErrorCode: 131"
                    self.present(alert, animated: true)
                }
                print("Email Sent")
                self.performSegue(withIdentifier: "LoginView", sender: nil)
            }
        }
    }
}

