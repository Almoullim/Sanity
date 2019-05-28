//
//  EditProfileViewController.swift
//  Sanity
//
//  Created by Ali on 5/28/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

class EditProfileViewController: UITableViewController {

    
    @IBOutlet weak var dateOfBirth: UILabel!
    @IBOutlet var table: UITableView!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    var datePickerIsHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func datePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        print(dateFormatter.string(from: datePicker.date))
        dateOfBirth.text = dateFormatter.string(from: datePicker.date)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case [1, 1]:
            return datePickerIsHidden ? 0.0 : 216.0
        default:
            return 44.0
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [1, 0]:
            tableView.beginUpdates()
            datePickerIsHidden = !datePickerIsHidden
            tableView.endUpdates()
        default:
            print("Wrong selection")
        }
    }
    
    
}
