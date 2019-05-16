//
//  CustomMovieCell.swift
//  Movies!
//
//  Created by Manuel on 5/14/19.
//  Copyright © 2019 ManuelRR. All rights reserved.
//

import UIKit

class CustomMovieCell: UITableViewCell {
    
    
    @IBOutlet var movieImageView: UIImageView!
    @IBOutlet var movieNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
