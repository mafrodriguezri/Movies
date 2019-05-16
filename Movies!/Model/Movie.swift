//
//  Movie.swift
//  Movies!
//
//  Created by Manuel on 5/14/19.
//  Copyright © 2019 ManuelRR. All rights reserved.
//

import Foundation
import RealmSwift

class Movie : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var category : String = ""
    @objc dynamic var overview : String = ""
    @objc dynamic var dateReleased : String = ""
    @objc dynamic var score : Float = 0
    @objc dynamic var popularity : Int = 0
    @objc dynamic var posterPath : String = ""
    @objc dynamic var colorHexCode : String = ""
    
}
