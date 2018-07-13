//
//  RecentSearchesTableViewCell.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/13/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import UIKit

class RecentSearchesTableViewCell: UITableViewCell {
    @IBOutlet weak var recentSearchLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func loadSearch(recentSearch: String){
        self.recentSearchLabel.text = recentSearch
    }
}
