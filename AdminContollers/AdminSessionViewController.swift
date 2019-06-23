//
//  AdminSessionViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/19/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AdminSessionViewController: UIViewController {
    // outlet
    @IBOutlet weak var FirstUserImage: DesignableUIImageView!
    @IBOutlet weak var FirstUserName: DesignableUILabel!
    @IBOutlet weak var FirstUserUserType: DesignableUILabel!
    @IBOutlet weak var FirstUserReview: UILabel!
    @IBOutlet weak var SessionTime: UILabel!
    @IBOutlet weak var SessionDuration: UILabel!
    @IBOutlet weak var SecoundUserImage: DesignableUIImageView!
    @IBOutlet weak var SecoundUserName: DesignableUILabel!
    @IBOutlet weak var SecoundUserUserType: DesignableUILabel!
    @IBOutlet weak var SecoundUserReview: UILabel!
    @IBOutlet weak var FirstUserRating: UILabel!
    @IBOutlet weak var SecondUserRatingLabel: UILabel!
    
    
    // pass info
    var sessionID: String?
    
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
        
        // get session info from datapase
        if let currentSession = sessionID {
            let docRef = db.collection("sessions").document(currentSession)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    if let data = document.data() {
                        self.getSession(data)
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
    
    func getSession(_ document: [String : Any]) {
        
        // set documnt information to outlets
        let helpseekeruser = document["helpSeekerUserName"] as? String
        getUserName(userName: helpseekeruser!) { helpSeeker in
                // get help seeker user name
                 self.FirstUserName.text = helpSeeker
            }
            
            
            self.FirstUserReview.text = document["helpSeekerReview"] as? String
            if let firstUserRating = document["helpSeekerRating"] as? Int {
                self.FirstUserRating.text = "\(String(firstUserRating))/5"
            }
        let volunteerUser = document["helperUserName"] as? String
            getUserName(userName: volunteerUser!) { volunteer in
                // get volunteer user name
                self.SecoundUserName.text = volunteer
            }
            self.SecoundUserReview.text = document["helperReview"] as? String
            if let secondUserRating = document["helperRating"] as? Int {
                self.SecondUserRatingLabel.text = "\(String(secondUserRating))/5"
            }
            self.FirstUserUserType.text = "Help Seeker"
            self.SecoundUserUserType.text = "Volunteer"
            if let sinceTimestamp = document["daysSince"] as? Timestamp {
                self.SessionTime.text = "Since " + timeSince(timestamp: sinceTimestamp)
            }
            if let durationTimestamp = document["duration"] as? String {
                self.SessionDuration.text = duration(duration: durationTimestamp)
            }
            
            
            // get storage path
            let storageRef = self.storage.reference()
            let imgRef = storageRef.child("images/" + helpseekeruser! + ".jpg")
            let imgRef2 = storageRef.child("images/" + volunteerUser! + ".jpg")
            
            // get images and assign to UIImage
            imgRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                print("image download started")
                URLSession.shared.dataTask(with: downloadURL) { data, response, error in
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async() {
                        print("image download finished")
                        self.FirstUserImage.image = image
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
                        self.SecoundUserImage.image = image
                    }
                    }.resume()
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


