//
//  ArticleViewController.swift
//  Sanity
//
//  Created by Ali on 6/7/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleTags: UILabel!
    @IBOutlet weak var articleDescription: UITextView!
    
    var articleTitleValue: String?
    var articleTagsValue: String?
    var articleDescriptionValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleTitle.text = articleTitleValue
        articleTags.text = articleTagsValue
        articleDescription.text = articleDescriptionValue?.replacingOccurrences(of: "\\n", with: "\n")
    }
}
