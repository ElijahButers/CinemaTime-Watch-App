/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation

class TicketOffice {
  
  static let sharedInstance = TicketOffice()
  
  lazy var movies: NSArray = {
    if let plistURL = NSBundle.mainBundle()
      .URLForResource("movies", withExtension: "plist"),
      let array = NSArray(contentsOfURL: plistURL) {
        return array
    }
    return NSArray()
  }()
  
  lazy var allMovies: [Movie] = {
    var movies = [Movie]()
    for section in self.movies {
      let moviesInSection = section["movies"] as! NSArray
      for movieDictionary in moviesInSection {
        let time = section["time"] as! String
        let movie = Movie(dictionary: movieDictionary as! NSDictionary, time: time)
        movies.append(movie)
      }
    }
    return movies
  }()
  
  let kPurchasedTickets = "PurchasedTickets"
  lazy var defaults = NSUserDefaults.standardUserDefaults()
  
  func movieTicketIsAlreadyPurchased(id:String) -> Bool {
    guard let purchasedIDs = purchasedMovieTicketIDs() else {
      return false
    }
    return purchasedIDs.filter({return $0 == id}).count > 0
  }
  
  func purchaseTicketForMovie(id: String) {
    var purchasedTickets = defaults.objectForKey(kPurchasedTickets) as? [String]
    if purchasedTickets == nil {
      purchasedTickets = [String]()
    }

    if !movieTicketIsAlreadyPurchased(id) {
      purchasedTickets?.append(id)
    }
    defaults.setObject(purchasedTickets, forKey: kPurchasedTickets)
    defaults.synchronize()
  }
  
  func purchaseTicketsForMovies(ids: [String]) {
    for id in ids {
      purchaseTicketForMovie(id)
    }
  }
  
  func purchasedMovieTicketIDs() -> [String]? {
    return defaults.objectForKey(kPurchasedTickets) as? [String]
  }
  
  func purchasedMovies() -> [Movie]? {
    guard let purchasedIDs = purchasedMovieTicketIDs() else {
      return nil
    }
    
    var purchasedMovies = [Movie]()
    for purchasedMovieID in purchasedIDs {
      if let movie = allMovies.filter({return purchasedMovieID == $0.id}).first {
        purchasedMovies.append(movie)
      }
    }
    return purchasedMovies.sort({$0.time.localizedCaseInsensitiveCompare($1.time) == NSComparisonResult.OrderedAscending})
  }
  
  // Movie Ratings
  
  func rateMovie(movieID: String, rating: String) {
    let key = "rating_\(movieID)"
    defaults.setObject(rating, forKey: key)
    defaults.synchronize()
  }
  
  func movieRatingForID(movieID: String) -> String {
    let key = "rating_\(movieID)"
    return defaults.objectForKey(key) as? String ?? "☆☆☆☆☆"
  }
}