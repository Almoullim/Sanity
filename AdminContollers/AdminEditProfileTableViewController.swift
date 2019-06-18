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
    @IBOutlet weak var Location: UITextField!
    @IBOutlet weak var Language: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    
    // cases
    var alreadyRan: Bool = false
    var imageChanged: Bool = false
    
    var username: String?
    var db: Firestore!
    var storage: Storage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        
        storage = Storage.storage()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if alreadyRan { return }
        
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("uid", isEqualTo: currentUser.uid)
                .getDocuments() { (querySnapshot, err) in
                    
                    if let data = querySnapshot?.documents[0].data() {
                        self.username = data["username"] as? String
                        self.UserNameInput.text = data["name"] as? String
                        
                        if let mobile = data["mobile"] as? String {
                            self.MobileInput.text = mobile
                        }
                        
                        if let timestamp = data["dob"] as? Timestamp {
                            // Construct days since
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd/MM/yyyy"
                            
                            self.DOBLable.text = dateFormatter.string(from: timestamp.dateValue())
                            self.DatePicker.date = timestamp.dateValue()
                            
                            self.DOBLable.textColor = .black
                        }
                        
                        self.Language.text = data["language"] as? String
                        self.Location.text = data["location"] as? String
                        
                        let storageRef = self.storage.reference()
                        let imgRef = storageRef.child("images/" + self.username! + ".jpg")
                        
                        imgRef.downloadURL { (url, error) in
                            guard let downloadURL = url else { return }
                            self.UserImage.downloaded(from: downloadURL)
                        }
                    }
            }
            
        }
        self.alreadyRan = true
    }
    
    
    @IBAction func imageClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Profile Image", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Choose from photos", style: .default , handler:{ (UIAlertAction)in
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Take a picture", style: .default , handler:{ (UIAlertAction)in
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.UserImage.image = image
            self.imageChanged = true
            dismiss(animated: true, completion: nil)
        }
    }

    
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        var dob: Timestamp? = nil
        
        if  let dateString = self.DOBLable.text,
            let date = dateFormatter.date(from: dateString) {
            dob = Timestamp(date: date)
        }
        
        let docData: [String: Any] = [
            "name": self.UserNameInput.text!,
            "language": self.Language.text!,
            "location": self.Location.text!,
            "mobile": self.MobileInput.text!,
            "dob": dob ?? NSNull(),
        ]
        
        self.db
            .collection("users")
            .document(self.username!)
            .setData(docData, merge: true)
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("user info successfully updated!")
                }
        }
        if !imageChanged {
            performSegue(withIdentifier: "backSetting", sender: sender)
            return
        }
        
        let storageRef = storage.reference()
        let imgRef = storageRef.child("images/" + self.username! + ".jpg")
        let imgData = UserImage.image?.jpegData(compressionQuality: 80.0)
        
        
        // Upload the file
        print("uploading image")
        imgRef.putData(imgData!, metadata: nil) { (metadata, error) in
            print("image uploading finished")
            self.performSegue(withIdentifier: "backSetting", sender: sender)
        }
    }
    
        
    @IBAction func cancelButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "backSetting", sender: sender)
    }
    
    @IBAction func datePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        DOBLable.text = dateFormatter.string(from: datePicker.date)
        self.DOBLable.textColor = .black
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
