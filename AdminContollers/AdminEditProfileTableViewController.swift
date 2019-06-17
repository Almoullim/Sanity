//
//  AdminEditProfileTableViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/15/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AdminEditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    var imagePicker = UIImagePickerController()
    @IBOutlet weak var UserImage: DesignableUIImageView!
    @IBOutlet weak var UserNameInput: UITextField!
    @IBOutlet weak var MobileInput: UITextField!
    @IBOutlet weak var DOBLable: UILabel!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var DatePickerCell: UITableViewCell!
    var datePickerIsHidden = true
    @IBOutlet weak var LanguageInput: NSLayoutConstraint!
    @IBOutlet weak var Location: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    
    // cases
    var alreadyRan: Bool = false
    var imageChanged: Bool = false
    
    var username: String?
    var db: Firestore!
    var storage: Storage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case [1, 2]:
            return datePickerIsHidden ? 0.0 : 216.0
        case [0, 0]:
            return 180.0
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [1, 1]:
            tableView.beginUpdates()
            datePickerIsHidden = !datePickerIsHidden
            tableView.endUpdates()
        default:
            print("Wrong selection")
        }
    }


}
