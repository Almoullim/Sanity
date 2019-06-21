//
//  EditProfileViewController.swift
//  Sanity
//
//  Created by Ali on 5/28/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class DoctorEditProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    var datePickerIsHidden = true
    @IBOutlet weak var datePicker: UIDatePicker!
    var imagePicker = UIImagePickerController()
    
    // inputs
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var dateOfBirth: UILabel!
    @IBOutlet weak var specialityInput: UITextField!
    @IBOutlet weak var languageInput: UITextField!
    @IBOutlet weak var locationInput: UITextField!
    @IBOutlet weak var imageView: DesignableUIImageView!
    @IBOutlet weak var mobileInput: UITextField!
    @IBOutlet weak var availabilitySwitch: UISwitch!
    @IBOutlet weak var addressInput: UITextField!
    
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
                        self.nameInput.text = data["name"] as? String
                        
                        if let mobile = data["mobile"] as? String {
                            self.mobileInput.text = mobile
                        }
                        
                        if let timestamp = data["dob"] as? Timestamp {
                            // Construct days since
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd/MM/yyyy"
                            
                            self.dateOfBirth.text = dateFormatter.string(from: timestamp.dateValue())
                            self.datePicker.date = timestamp.dateValue()
                            
                            self.dateOfBirth.textColor = .black
                        }
                        
                        self.specialityInput.text = data["issue"] as? String
                        self.languageInput.text = data["language"] as? String
                        self.locationInput.text = data["location"] as? String
                        
                        if let available = data["available"] as? Bool {
                            self.availabilitySwitch.setOn(available, animated: true)
                        }
                        
                        self.addressInput.text = data["address"] as? String
                        
                        let storageRef = self.storage.reference()
                        let imgRef = storageRef.child("images/" + self.username! + ".jpg")
                        
                        imgRef.downloadURL { (url, error) in
                            guard let downloadURL = url else { return }
                            self.imageView.downloaded(from: downloadURL)
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
            self.imageView.image = image
            self.imageChanged = true
            dismiss(animated: true, completion: nil)
        }
    }
    

    @IBAction func saveButtonClicked(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        var dob: Timestamp? = nil
        
        if  let dateString = self.dateOfBirth.text,
            let date = dateFormatter.date(from: dateString) {
            dob = Timestamp(date: date)
        }
        
        let docData: [String: Any] = [
            "name": self.nameInput.text!,
            "speciality":self.specialityInput.text!,
            "language": self.languageInput.text!,
            "location": self.locationInput.text!,
            "mobile": self.mobileInput.text!,
            "available": self.availabilitySwitch.isOn,
            "address": self.addressInput.text!,
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
            self.dismiss(animated: true, completion: nil)
            return
        }

        let storageRef = storage.reference()
        let imgRef = storageRef.child("images/" + self.username! + ".jpg")
        let imgData = imageView.image?.jpegData(compressionQuality: 80.0)


        // Upload the file
        print("uploading image")
        imgRef.putData(imgData!, metadata: nil) { (metadata, error) in
            print("image uploading finished")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func datePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateOfBirth.text = dateFormatter.string(from: datePicker.date)
        self.dateOfBirth.textColor = .black
    }
    
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
