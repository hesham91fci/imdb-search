//
//  MovieTableViewCell.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import UIKit
import Kingfisher
class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var moviewOverviewLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadMovie(movie:Movie){
        self.nameLabel.text = movie.name
        if movie.poster != nil {
            let url = URL(string: NSLocalizedString("POSTERS_ENDPOINT", comment: "comment") + movie.poster)
            self.moviePosterImage.kf.setImage(with: url)
        }
        if(movie.releaseDate.count != 0){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let movieDate = dateFormatter.date(from: movie.releaseDate)
            
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            self.releaseDateLabel.text = dateFormatter.string(from: movieDate!)
        }
        self.moviewOverviewLabel.text = movie.overview
    }

}
