//
//  ArticelsViewController.swift
//  Sanity
//
//  Created by Ali Hubail on 6/21/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class ArticelsViewController: UITableViewController {
    // firebase connection
    var db: Firestore!
    // outlets
    @IBOutlet weak var ReadingsTable: UITableView!
    // article collection
    var articles: [Article] = []
    // pass info
    var selectedArticle: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // firebase api
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // delegate
        ReadingsTable.delegate = self
        ReadingsTable.dataSource = self
        // load all articles
        loadArticles()
    }
    
    func loadArticles() {
        // set collection [table]
        let collection = db.collection("articles")
        
        // get all documents using firebase api and assign to new article
        collection.getDocuments() { (querySnapshot, err) in
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
                    
                    // add new article to the articles collection
                    self.articles.append(Article(title: title, uid: uid, tags: tags, description: description))
                }
                // reload table
                self.ReadingsTable.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // get articles count and assign to rows count
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // set row height to 72
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // assign cell article to variable
        tableView.deselectRow(at: indexPath, animated: true)
        selectedArticle = self.articles[indexPath.row]
        performSegue(withIdentifier: "editArticle", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass info to next view
        if segue.identifier == "editArticle" {
            let view = segue.destination as? AddArticleViewController
            
            view?.articleIDValue = selectedArticle?.uid
            view?.articleTitleValue = selectedArticle?.title
            view?.articleTagsValue = selectedArticle?.tags
            view?.articleDescriptionValue = selectedArticle?.description
        }
    }
    
    @IBAction func AddClicked(_ sender: Any) {
        // move to next view
        performSegue(withIdentifier: "addArticle", sender: nil)
    }
    
    
    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // assign article info to cell
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ReadingCell") as? ReadingCell
        
        cell?.title.text = self.articles[indexPath.row].title
        cell?.articleId = self.articles[indexPath.row].uid
        cell?.tags.text = self.articles[indexPath.row].tags

        return cell!
    }
    @IBAction func unwindToArticles(unwindSegue: UIStoryboardSegue) {
        // unwind from add article
    }

}
