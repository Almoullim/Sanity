//
//  DoctorArticleViewController.swift
//  Sanity
//
//  Created by Ali on 6/21/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class DoctorArticleViewController: UIViewController {

    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleTags: UILabel!
    @IBOutlet weak var articleDescription: UITextView!
    
    var articleTitleValue: String?
    var articleTagsValue: String?
    var articleDescriptionValue: String?
    var articleId: String?
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        articleTitle.text = articleTitleValue
        articleTags.text = articleTagsValue
        articleDescription.text = articleDescriptionValue?.replacingOccurrences(of: "\\n", with: "\n")
    }
    
    @IBAction func removeArticle(_ sender: Any) {
        self.db
            .collection("articles")
            .document(articleId!)
            .delete()
        self.performSegue(withIdentifier: "unwindToReadingList", sender: nil)
    }
    
    @IBAction func editArticle(_ sender: Any) {
        self.performSegue(withIdentifier: "editArticle", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editArticle" {
            guard let view = segue.destination as? DoctorAddArticleViewController else { return }
            view.articleIDValue = self.articleId
        }
    }
}
