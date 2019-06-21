//
//  DoctorAddArticleViewController.swift
//  Sanity
//
//  Created by Ali on 6/21/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class DoctorAddArticleViewController: UITableViewController {
    // outlets
    @IBOutlet weak var TitleInput: UITextField!
    @IBOutlet weak var Article: UITextView!
    @IBOutlet weak var TagsInput: UITextField!
    
    // firebase connection
    var db: Firestore!
    
    // pass info
    var articleIDValue: String?
    var articleTitleValue: String?
    var articleTagsValue: String?
    var articleDescriptionValue: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // firebase api
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set outlets info using passed info if available
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToReadingList", sender: nil)
    }
    
    @IBAction func AddClicked(_ sender: Any) {
        // get outlets values and assign to array
        let docData: [String: Any] = [
            "title": self.TitleInput.text!,
            "description": self.Article.text!,
            "tags": self.TagsInput.text!,
            
            ]
        if let id = self.articleIDValue {
            // update article value in database if pass info is not null
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
        } else {
            // add new article to database
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
        
        self.performSegue(withIdentifier: "unwindToReadingList", sender: nil)
        
    }
}
