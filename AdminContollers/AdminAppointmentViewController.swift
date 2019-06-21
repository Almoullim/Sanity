//
//  AdminAppointmentViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/21/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AdminAppointmentViewController: UIViewController {

    // outlet
    @IBOutlet weak var helpSeekerImage: DesignableUIImageView!
    @IBOutlet weak var helpSeekerName: DesignableUILabel!
    @IBOutlet weak var appointmentTime: UILabel!
    @IBOutlet weak var appointmentDate: UILabel!
    @IBOutlet weak var doctorImage: DesignableUIImageView!
    @IBOutlet weak var doctorName: DesignableUILabel!
    @IBOutlet weak var appointmentStatus: UILabel!
    
    
    // pass info
    var appointmentID: String?
    
    //
    var isApproved: Bool?
    var isCompleted: Bool?

    // firebase connection
    var db: Firestore!
    var storage: Storage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // firebase api code
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get session info from datapase if passed ID is available using query
        // firebase api code to get single documnt code isn't work
        if let currentAppointment = appointmentID {
            let query = db.collection("appointments").whereField("appointmentID", isEqualTo: currentAppointment)
            query.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.getAppointments(querySnapshot!.documents)
                }
            }
        }
        
    }
    
    func getAppointments(_ documents: [QueryDocumentSnapshot]) {
        
        // set documnt information to outlets
        for document in documents {
            self.helpSeekerName.text = document.data()["helpSeekerName"] as? String
            self.doctorName.text = document.data()["doctorName"] as? String
            if let timeStamp = document.data()["appointmentDate"] as? Timestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            self.appointmentDate.text = dateFormatter.string(from: timeStamp.dateValue())
            dateFormatter.timeStyle = .long
            self.appointmentTime.text = dateFormatter.string(from: timeStamp.dateValue())
            }
            self.isApproved = document.data()["isApproved"] as? Bool
            self.isCompleted = document.data()["isCompleted"] as? Bool
            if isCompleted! {
                self.appointmentStatus.text = "Completed"
            } else if isApproved! {
                self.appointmentStatus.text = "Approved"
            } else {
                self.appointmentStatus.text = "Pending"
            }
            
            // get storage path
            let storageRef = self.storage.reference()
            let imgRef = storageRef.child("images/" + self.helpSeekerName.text! + ".jpg")
            let imgRef2 = storageRef.child("images/" + self.doctorName.text! + ".jpg")
            
            // get images and assign to UIImage
            imgRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                print("image download started")
                URLSession.shared.dataTask(with: downloadURL) { data, response, error in
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async() {
                        print("image download finished")
                        self.helpSeekerImage.image = image
                    }
                    }.resume()
            }
            imgRef2.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                print("image download started")
                URLSession.shared.dataTask(with: downloadURL) { data, response, error in
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async() {
                        print("image download finished")
                        self.doctorImage.image = image
                    }
                    }.resume()
            }
        }
    }
    

}
