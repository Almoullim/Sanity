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
            
            let docRef = db.collection("appointments").document(currentAppointment)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    if let data = document.data() {
                        self.getAppointments(data)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        
    }
    func getUserName(userName: String, completion: @escaping (String) -> Void) {
        
        // get user full name using function with closure
        // code reference
        // https://stackoverflow.com/questions/54988558/how-to-return-expected-value-from-within-another-function-in-swift
        let docRef = db.collection("users").document(userName)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion("")
                
            } else {
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    if let data = document.data() {
                        completion((data["name"] as? String)!)
                    }
                    
                }
            }
        }
    }
    
    func getAppointments(_ data: [String : Any]) {
        
        // set documnt information to outlets
            let doctorUser = data["doctorName"] as? String
            getUserName(userName: doctorUser!) { doctor in
            // get doctor user name
            self.doctorName.text = doctor
            }
        let helpSeekerUserName = data["helpSeekerUserName"] as? String
            self.helpSeekerName.text = data["helpSeekerName"] as? String
            if let timeStamp = data["appointmentDate"] as? Timestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            self.appointmentDate.text = dateFormatter.string(from: timeStamp.dateValue())
            dateFormatter.timeStyle = .short
            self.appointmentTime.text = dateFormatter.string(from: timeStamp.dateValue())
            }
            self.isApproved = data["isApproved"] as? Bool
            self.isCompleted = data["isCompleted"] as? Bool
            if isCompleted! {
                self.appointmentStatus.text = "Completed"
            } else if isApproved! {
                self.appointmentStatus.text = "Approved"
            } else {
                self.appointmentStatus.text = "Pending"
            }
            
            // get storage path
            let storageRef = self.storage.reference()
            let imgRef = storageRef.child("images/" + helpSeekerUserName! + ".jpg")
            let imgRef2 = storageRef.child("images/" + doctorUser! + ".jpg")
            
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

