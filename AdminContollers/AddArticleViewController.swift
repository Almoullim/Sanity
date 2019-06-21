//
//  AddArticleViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/21/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class AddArticleViewController: UITableViewController {
    
    
    @IBOutlet weak var TitleInput: UITextField!
    @IBOutlet weak var Article: UITextView!
    @IBOutlet weak var TagsInput: UITextField!
    
    var db: Firestore!

    // pass info
    var articleIDValue: String?
    var articleTitleValue: String?
    var articleTagsValue: String?
    var articleDescriptionValue: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if let title = self.articleTitleValue {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(AddQuestionTableViewController.AddClicked(_:)))
            self.navigationItem.title = "Edit Article"

            self.TitleInput.text = title
        }
        if let description = self.articleDescriptionValue {
            self.Article.text = description
        }
        if let tags = self.self.articleTagsValue {
            self.TagsInput.text = tags
        }
      
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
       // dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddClicked(_ sender: Any) {
        
        let docData: [String: Any] = [
            "title": self.TitleInput.text!,
            "description": self.Article.text!,
            "tags": self.TagsInput.text!,

        ]
        if let id = self.articleIDValue {

        self.db
            .collection("articles")
            .document(id)
            .setData(docData, merge: true)
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Question updated!")
                }
        }
        }else {
            self.db
                .collection("articles")
                .document()
                .setData(docData, merge: true)
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Question updated!")
                    }
            }
        }
        
        // dismiss(animated: true, completion: nil)
        
    }
    
    


}
