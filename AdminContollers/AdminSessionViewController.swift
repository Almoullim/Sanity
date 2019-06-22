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
        
        // get session info from datapase if passed ID is available using query
        // firebase api code to get single documnt code isn't work
        if let currentSession = sessionID {
            let query = db.collection("sessions").whereField("sessionID", isEqualTo: currentSession)
                query.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        self.getSession(querySnapshot!.documents)
                    }
                }
        }
        
    }
    
    func getSession(_ documents: [QueryDocumentSnapshot]) {
        
        // set documnt information to outlets
        for document in documents {
            let helpSeekerUserName = document.data()["helpSeekerUserName"] as? String

            var docRef = db.collection("users").document(helpSeekerUserName!)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    if let data = document.data() {
                        self.FirstUserName.text = data["name"] as? String
                    }
                } else {
                    print("Document does not exist")
                }
            }
            self.FirstUserReview.text = document.data()["helpSeekerReview"] as? String
            if let firstUserRating = document.data()["helpSeekerRating"] as? Int {
                self.FirstUserRating.text = "\(String(firstUserRating))/5"
            }
            let helperUserName = document.data()["helperUserName"] as? String

            docRef = db.collection("users").document(helperUserName!)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    if let data = document.data() {
                        self.SecoundUserName.text = data["name"] as? String
                    }
                } else {
                    print("Document does not exist")
                }
            }
            self.SecoundUserReview.text = document.data()["helperReview"] as? String
            if let secondUserRating = document.data()["helperRating"] as? Int {
                self.SecondUserRatingLabel.text = "\(String(secondUserRating))/5"
            }
            self.FirstUserUserType.text = "Help Seeker"
            self.SecoundUserUserType.text = "Volunteer"
            if let sinceTimestamp = document.data()["daysSince"] as? Timestamp {
                self.SessionTime.text = "Since " + timeSince(timestamp: sinceTimestamp)
            }
            if let durationTimestamp = document.data()["duration"] as? String {
                self.SessionDuration.text = duration(duration: durationTimestamp)
            }
            
            
            // get storage path
            let storageRef = self.storage.reference()
            let imgRef = storageRef.child("images/" + self.FirstUserName.text! + ".jpg")
            let imgRef2 = storageRef.child("images/" + self.SecoundUserName.text! + ".jpg")
            
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
    
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


