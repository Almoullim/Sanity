//
//  VolunteersViewController.swift
//  Sanity
//
//  Created by Ali on 3/31/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

class VolunteersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var VolunteersTable: UITableView!
    
    var volunteers = [1,2,3,4,5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "VolunteerCell") as? VolunteerCell
    
        cell?.volunteerName.text = "Ali Almoullim"
        cell?.volunteerInfo.text = "Rating +4"
        cell?.volunteerImage.image = UIImage(named: "women")
        
        return cell!
    }
}
