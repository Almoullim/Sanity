//
//  ReadingCell.swift
//  Sanity
//
//  Created by Ali on 6/5/19.
//  Copyright © 2019 Almoullim. All rights reserved.
//

import UIKit

class ReadingCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var tags: DesignableUILabel!
    var articleId: String?
}
