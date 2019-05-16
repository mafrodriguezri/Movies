//
//  DetailsViewController.swift
//  Movies!
//
//  Created by Manuel on 5/15/19.
//  Copyright © 2019 ManuelRR. All rights reserved.
//

import UIKit
import RealmSwift

class DetailsViewController: UIViewController {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    
    @IBOutlet var releaseDateTitle: UILabel!
    @IBOutlet var scoreTitle: UILabel!
    @IBOutlet var overviewTitle: UILabel!
    
    let titleLabel = UILabel()
    
    var selectedMovie : Movie?
    var internedEnabled : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    
    //MARK: - Populate the UI elements with the movie details
    
    override func viewWillAppear(_ animated: Bool) {
        
        print(selectedMovie as Any)
        
        let imageURL = "https://image.tmdb.org/t/p/w400" + (selectedMovie?.posterPath ?? "")
        
        if let url = NSURL(string: imageURL) {
            if let data = NSData(contentsOf: url as URL) {
                if let image = UIImage(data: data as Data) {
                    posterImageView.image = image
                } 
            }
        }
        
        if internedEnabled == false {
            posterImageView.image = UIImage(named: "noImageAvailable")
        }
        
        releaseDateLabel.text = selectedMovie?.dateReleased
        
        if selectedMovie?.score == 0 {
            scoreLabel.text = "No score yet"
        } else {
            scoreLabel.text = "\(selectedMovie!.score)"
        }
        
        overviewLabel.text = selectedMovie?.overview
        
        titleLabel.text = selectedMovie?.title
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 25.0)
        titleLabel.adjustsFontSizeToFitWidth = true
        navigationItem.titleView = titleLabel
        
        updateColor(withHexCode: selectedMovie?.colorHexCode)
    }
    
    //MARK: - Function to color the view with the color extracted from the movie poster
    
    func updateColor(withHexCode hexCode: String?) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        
        guard let movieColor = UIColor(hexString: hexCode!) else {fatalError()}
        
        navBar.barTintColor = movieColor.darken(byPercentage: 0.2)
        navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: navBar.barTintColor!, isFlat: true)
        titleLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: navBar.barTintColor!, isFlat: true)
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(contrastingBlackOrWhiteColorOn: navBar.barTintColor!, isFlat: true)]
        
        view.backgroundColor = movieColor
        
        releaseDateTitle.textColor = UIColor(contrastingBlackOrWhiteColorOn: movieColor, isFlat: true)
        releaseDateLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: movieColor, isFlat: true)

        scoreTitle.textColor = UIColor(contrastingBlackOrWhiteColorOn: movieColor, isFlat: true)
        scoreLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: movieColor, isFlat: true)
        
        overviewTitle.textColor = UIColor(contrastingBlackOrWhiteColorOn: movieColor, isFlat: true)
        overviewLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: movieColor, isFlat: true)
    }
}
