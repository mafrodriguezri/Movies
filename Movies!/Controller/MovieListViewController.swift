//
//  ViewController.swift
//  Movies!
//
//  Created by Manuel on 5/14/19.
//  Copyright © 2019 ManuelRR. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire
import Network
import SVProgressHUD
import ChameleonFramework

class MovieListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let realm = try! Realm()
    var moviesList : Results<Movie>?
    var categoryTracker : String = "popular"
    var jsonCount : Int = 0
    
    let monitor = NWPathMonitor()
    var internetEnabled : Bool = false
    let queue = DispatchQueue(label: "Monitor")
    
    let baseMovieURL = "https://api.themoviedb.org/3/movie/"
    let parameters : [String : String] = ["Content-Type":"application/json;charset=utf-8", "api_key":"put your API key here", "sort_by":"original_order.asc", "region":"US"]
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var moviesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We're connected!")
                self.internetEnabled = true
            } else {
                print("No connection.")
                self.internetEnabled = false
            }
        }
                                                //Checking for an internet connection
        monitor.start(queue: queue)
        
        moviesTableView.rowHeight = 120

        loadMovies()
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        
        moviesTableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "customMovieCell")
    }

    
    //MARK: - TableView DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesList?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMovieCell", for: indexPath) as! CustomMovieCell
        
        cell.movieNameLabel.text = moviesList?[indexPath.row].title ?? ""

        let imageURL = "https://image.tmdb.org/t/p/w200" + (moviesList?[indexPath.row].posterPath ?? "")
        
        if internetEnabled == true {
            if let url = NSURL(string: imageURL) {
                if let data = NSData(contentsOf: url as URL) {
                    if let image = UIImage(data: data as Data) {
                        cell.movieImageView.image = image
                        
                        // Getting the color from the movie poster in order to apply it to the cell
                        do {
                            try self.realm.write {
                                moviesList?[indexPath.row].colorHexCode = AverageColorFromImage(image).hexValue()
                            }
                        } catch {
                            print("Error saving color, \(error)")
                        }
                    }
                }
            }
        }
        else {
            cell.movieImageView.image = UIImage(named: "noImageAvailable")
        }
        
        guard let cellColorCode = moviesList?[indexPath.row].colorHexCode else {fatalError()}
        guard let cellColor = UIColor(hexString: cellColorCode) else {fatalError()}
        
        cell.backgroundColor = cellColor
        cell.movieNameLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
        
        return cell
    }
    
    
    // MARK: - TableView delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if moviesList?[indexPath.row].posterPath != nil {
            performSegue(withIdentifier: "goToDetails", sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! DetailsViewController
        
        if let indexPath = moviesTableView.indexPathForSelectedRow {
            destinationVC.selectedMovie = moviesList?[indexPath.row]
            destinationVC.internedEnabled = internetEnabled
        }
    }
    
    
    //MARK: - Networking using Alamofire
    
    func getMovieApi(withURL url: String, category: String) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            
            if response.result.isSuccess {
                
                let movieJSON : JSON = JSON(response.result.value!)
                self.getMovieDetails(json: movieJSON, category: category)
                
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    //MARK: - Parsing the JSON data
    
    func getMovieDetails(json: JSON, category: String) {
        
        if let _ = json["results"][0]["title"].string {
            
            let moviesCount = json["results"].count
            
            for movieNumber in 0...(moviesCount-1) {
                
                let newMovie = Movie()
                newMovie.title = json["results"][movieNumber]["title"].stringValue
                newMovie.dateReleased = json["results"][movieNumber]["release_date"].stringValue
                newMovie.overview = json["results"][movieNumber]["overview"].stringValue
                newMovie.category = category
                newMovie.score = json["results"][movieNumber]["vote_average"].floatValue
                newMovie.popularity = json["results"][movieNumber]["popularity"].intValue
                
                newMovie.posterPath = "\(json["results"][movieNumber]["poster_path"].stringValue)"
                
                saveMovie(newMovie)
            }
        }
        print("json"+category)
        jsonCount += 1
        
        if jsonCount == 3 {
            jsonCount = 0
            self.loadMovies()
        }
    }
    
    
    //MARK: - Category selection
    
    @IBAction func categorySelected(_ sender: UIBarButtonItem) {
        
        SVProgressHUD.show()
        
        if sender.tag == 1 {
            categoryTracker = "popular"
            title = "Popular"
        }
        else if sender.tag == 2 {
            categoryTracker = "top_rated"
            title = "Top Rated"
        }
        else if sender.tag == 3 {
            categoryTracker = "upcoming"
            title = "Upcoming"
        }
        
        loadMovies()
    }
    
    
    //MARK: - Update movie lists
    
    @IBAction func refreshLists(_ sender: UIBarButtonItem) {
        
        if internetEnabled == true {
            SVProgressHUD.show()
            
            do {
                try realm.write {
                    realm.deleteAll()
                }
            } catch {
                print("Error deleting items, \(error)")
            }
            
            getMovieApi(withURL: baseMovieURL+"popular", category: "popular")
            getMovieApi(withURL: baseMovieURL+"top_rated", category: "top_rated")
            getMovieApi(withURL: baseMovieURL+"upcoming", category: "upcoming")
        }
        else {
            let alert = UIAlertController(title: nil, message: "No connection detected.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Persisting movie data using Realm
    
    func saveMovie(_ movie: Movie) {
        do {
            try realm.write {
                realm.add(movie)
            }
        } catch {
            print("Error saving movies, \(error)")
        }
    }
    
    func loadMovies() {
        
        print("loadMovies"+"\(categoryTracker)")
        moviesList = realm.objects(Movie.self)
        
        if categoryTracker == "popular" {
            moviesList = moviesList?.filter("category CONTAINS %@", "popular").sorted(byKeyPath: "popularity", ascending: false)
        }
        else if categoryTracker == "top_rated" {
            moviesList = moviesList?.filter("category CONTAINS %@", "top_rated").sorted(byKeyPath: "score", ascending: false)
        }
        else if categoryTracker == "upcoming" {
            moviesList = moviesList?.filter("category CONTAINS %@", "upcoming").sorted(byKeyPath: "dateReleased", ascending: true)
        }
    
        moviesTableView.reloadData()
        
        SVProgressHUD.dismiss()
    }
}

//MARK: - Search bar methods

extension MovieListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        title = "Search"
        
        moviesList = moviesList?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        moviesTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            if categoryTracker == "popular" {
                title = "Popular"
            }
            else if categoryTracker == "top_rated"{
                title = "Top Rated"
            }
            else if categoryTracker == "upcoming" {
                title = "Upcoming"
            }
            
            loadMovies()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
