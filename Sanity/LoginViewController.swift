//
//  LoginViewController.swift
//  MP Project
//
//  Created by Ali on 3/30/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // Google Firestore connection
    var db: Firestore!
    
    // Login objects
    @IBOutlet var loginUsername: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginActivity: UIActivityIndicatorView!
    
    // Passed data
    var username: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change UITextField's placeholder color
        loginUsername.attributedPlaceholder = NSAttributedString(string: "Username..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        loginPassword.attributedPlaceholder = NSAttributedString(string: "Password..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        
        self.hideKeyboardWhenTappedAround()
        // [END setup]
        
        db = Firestore.firestore()
        
        if let username = self.username {
            self.loginUsername.text = username
        }
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0 {
//                self.view.frame.origin.y -= keyboardSize.height - 200
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
//    }
    
    // Set the stuatus bar content to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        // Create an alert for a failed login/empty field
        let alert = UIAlertController(title: "Wrong Username/Password", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        
        // Make sure the login fields are not empty
        if self.loginUsername.text?.isEmpty == true || self.loginPassword.text?.isEmpty == true {
            alert.title = "Please fill all the fields"
            self.present(alert, animated: true)
            return
        }
        
        // Set the button to 'empty' when the its disabled
        loginBtn.setTitle("", for: .disabled)
        
        // Show the activityIndicator and disable the button
        loginActivity.startAnimating()
        loginBtn.isEnabled = false
        
        let loginUsername = self.loginUsername.text!
        
        db.collection("users").whereField("username", isEqualTo: loginUsername)
            .getDocuments() { (querySnapshot, err) in
                
                self.loginActivity.stopAnimating()
                self.loginBtn.isEnabled = true
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                }
                
                guard (querySnapshot?.documents.count)! > 0 else {
                    print("ERROR: username not found")
                    
                    alert.title = "Wrong Username/Password"
                    self.present(alert, animated: true)
                    return
                }
                
                guard let loginEmail = querySnapshot?.documents[0]["email"] as? String else { return }
                
                Auth.auth().signIn(withEmail: loginEmail, password: self.loginPassword.text!) { [weak self] result, error in
                    guard let strongSelf = self else { return }
                    
                    // enable the button and hide the activityIndicator
                    strongSelf.loginActivity.stopAnimating()
                    strongSelf.loginBtn.isEnabled = true
                    
                    if result == nil {
                        print("ERROR: password incorrect")
                        
                        alert.title = "Wrong Username/Password"
                        strongSelf.present(alert, animated: true)
                    } else {
                        guard let name = querySnapshot?.documents[0]["name"] as? String else { return }
                        
                        alert.title = "Welcome, " + name
                        alert.message = result!.user.uid + "/n" + result!.user.email!
                        strongSelf.present(alert, animated: true)
                    }
                }
                
                
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
