//
//  ReadingsViewController.swift
//  Sanity
//
//  Created by Ali on 6/5/19.
//  Copyright © 2019 Almoullim. All rights reserved.
// UITableViewDataSource, UITableViewDelegate

import UIKit
import Firebase

class ReadingsViewController: UITableViewController {
    
    var db: Firestore!
    
    @IBOutlet weak var ReadingsTable: UITableView!
    
    var articles: [Article] = []
    var selectedArticle: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        ReadingsTable.delegate = self
        ReadingsTable.dataSource = self
        
        loadArticles()
    }
    
    func loadArticles() {
        let query = db.collection("articles")
        
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting articles: \(err)")
            } else {
                let articles = querySnapshot!.documents
                
                for articleDoc in articles {
                    let article = articleDoc.data()
                    
                    let uid = articleDoc.documentID
                    let title = article["title"] as! String
                    let tags = article["tags"] as! String
                    let description = article["description"] as! String
                    
                    self.articles.append(Article(title: title, uid: uid, tags: tags, description: description))
                }
                
                self.ReadingsTable.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedArticle = self.articles[indexPath.row]
        performSegue(withIdentifier: "Article", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Article" {
            let view = segue.destination as? VolunteerArticleViewController

            view?.articleTitleValue = selectedArticle?.title
            view?.articleTagsValue = selectedArticle?.tags
            view?.articleDescriptionValue = selectedArticle?.description
        }
    }
    
    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ReadingCell") as? ReadingCell
        
        cell?.title.text = self.articles[indexPath.row].title
        cell?.articleId = self.articles[indexPath.row].uid
        cell?.tags.text = self.articles[indexPath.row].tags
        
        return cell!
    }

}
