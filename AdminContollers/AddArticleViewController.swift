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
    
    
    @IBAction func AddClicked(_ sender: Any) {
        // go back to articles list
        performSegue(withIdentifier: "articles", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "articles" {
            // get outlets values and assign to array
            if sender == nil {
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
                            print("article updated!")
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
                            print("Error insert document: \(err)")
                        } else {
                            print("article insert!")
                        }
                }
            }
            
        }
      }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            if self.articleIDValue != nil {
                return 1
            } else {
                return 0
            }        default:
            return 0
            
            
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // assign cell article to variable
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [1, 0]:
            if let id = self.articleIDValue {
                db.collection("articles").document(id).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                performSegue(withIdentifier: "articles", sender: "delete")
            }
        default:
            break
        }
        
        
    }
    
    


}
