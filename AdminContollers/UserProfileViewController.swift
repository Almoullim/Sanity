//
//  UserProfileViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/15/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    
    @IBOutlet weak var UserImage: UIImageView!
    
    @IBOutlet weak var UserName: DesignableUILabel!
    @IBOutlet weak var MemberSince: UILabel!
    @IBOutlet weak var Location: UILabel!
    @IBOutlet weak var Age: UILabel!
    @IBOutlet weak var CallsNumber: UILabel!
    @IBOutlet weak var CallsLable: UILabel!
    @IBOutlet weak var Speciality: UILabel!
    @IBOutlet weak var SpecialityLable: UILabel!
    @IBOutlet weak var Language: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
