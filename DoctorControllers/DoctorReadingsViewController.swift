//
//  DoctorReadingsViewController.swift
//  Sanity
//
//  Created by Ali on 6/21/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit
import Firebase

class DoctorReadingsViewController: UITableViewController {

    var db: Firestore!
    
    @IBOutlet weak var ReadingsTable: UITableView!
    let refreshControlObj: UIRefreshControl = UIRefreshControl()
    
    var articles: [Article] = []
    var selectedArticle: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        ReadingsTable.refreshControl = self.refreshControlObj
        ReadingsTable.refreshControl?.addTarget(self, action: #selector(loadArticles), for: .valueChanged)
        
        ReadingsTable.delegate = self
        ReadingsTable.dataSource = self
        
        loadArticles()
    }
    
    @objc func loadArticles() {
        let query = db.collection("articles")
        self.articles = []
        self.ReadingsTable.reloadData()
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
                self.refreshControlObj.endRefreshing()
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
    
    @IBAction func unwindToReadingsList(segue:UIStoryboardSegue) {
        loadArticles()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Article" {
            let view = segue.destination as? DoctorArticleViewController
            
            view?.articleTitleValue = selectedArticle?.title
            view?.articleTagsValue = selectedArticle?.tags
            view?.articleDescriptionValue = selectedArticle?.description
            view?.articleId = selectedArticle?.uid
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
