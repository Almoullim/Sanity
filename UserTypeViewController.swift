//
//  UserTypeViewController.swift
//  MP Project
//
//  Created by Ali on 3/30/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

class UserTypeViewController: UIViewController {

    var userType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation
    
    @IBAction func helpSeekerClicked(_ sender: UIButton) {
        userType = "help-seeker"
        self.performSegue(withIdentifier: "RegisterView", sender: nil)
    }
    
    @IBAction func volunteerClicked(_ sender: UIButton) {
        userType = "volunteer"
        self.performSegue(withIdentifier: "RegisterView", sender: nil)
    }
    
    @IBAction func doctorClicked(_ sender: UIButton) {
        userType = "doctor"
        self.performSegue(withIdentifier: "RegisterView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterView" {
            let nav = segue.destination as? UINavigationController
            let view = nav?.viewControllers.first as? RegisterViewController
            view?.userType = self.userType
        }
    }

}
