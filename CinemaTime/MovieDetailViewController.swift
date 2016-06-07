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

import UIKit
import WatchConnectivity

class MovieDetailViewController: UIViewController {
  
  @IBOutlet weak var poster: UIImageView!
  @IBOutlet weak var movieTitle: UILabel!
  @IBOutlet weak var synopsis: UILabel!
  @IBOutlet weak var time: UILabel!
  @IBOutlet weak var director: UILabel!
  @IBOutlet weak var actors: UILabel!
  @IBOutlet weak var rating: UIButton!
  @IBOutlet weak var buyTicketButton: UIButton!
  @IBOutlet weak var QRImageView: UIImageView!
  
  var movie: Movie!
  lazy var notificationCenter: NSNotificationCenter = {
    return NSNotificationCenter.defaultCenter()
    }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = movie.title
    movieTitle.text = movie.title
    time.text = movie.time
    synopsis.text = movie.synopsis
    poster.image = UIImage(named: movie.poster)
    director.text = movie.director
    actors.text = movie.actors
    rating.setTitle(TicketOffice.sharedInstance.movieRatingForID(movie.id), forState: .Normal)
    if TicketOffice.sharedInstance.movieTicketIsAlreadyPurchased(movie.id) {
        let qrCode = QRCode(movie.id)
        QRImageView.image = qrCode?.image
        buyTicketButton.hidden = true
    } else {
        QRImageView.hidden = true
    }
  }
  
  @IBAction func butTicketWasTapped(sender: UIButton) {

    let alert = UIAlertController(title: "Purchase Ticket", message: "Are you sure you want to purchase 1 ticket for $8.50?", preferredStyle: .Alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alert.addAction(cancelAction)
    
    let buyAction = UIAlertAction(title: "Buy", style: .Default) {
      (action:UIAlertAction) -> Void in
      let ticketOffice = TicketOffice.sharedInstance
      ticketOffice.purchaseTicketForMovie(self.movie.id)
      
      
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(NotificationPurchasedMovieOnPhone, object: self.movie.id)
      }
      
      self.navigationController?.popToRootViewControllerAnimated(true)
    }
    alert.addAction(buyAction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
    
  @IBAction func ratingWasTapped(sender: UIButton) {
    
    let alert = UIAlertController(title: "Rate \(self.movie.title)", message: nil, preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    let oneAction = UIAlertAction(title: "★☆☆☆☆", style: .Default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }
    let twoAction = UIAlertAction(title: "★★☆☆☆", style: .Default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }
    let threeAction = UIAlertAction(title: "★★★☆☆", style: .Default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }
    let fourAction = UIAlertAction(title: "★★★★☆", style: .Default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }
    let fiveAction = UIAlertAction(title: "★★★★★", style: .Default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }

    alert.addAction(oneAction)
    alert.addAction(twoAction)
    alert.addAction(threeAction)
    alert.addAction(fourAction)
    alert.addAction(fiveAction)
    alert.addAction(cancelAction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func rateMovieWithRating(rating: String) {
    TicketOffice.sharedInstance.rateMovie(movie.id, rating: rating)
    sendRatingToWatch(rating)
    self.rating.setTitle(rating, forState: .Normal)
  }
  
  // MARK: - Watch Connectivity
  
  private func sendRatingToWatch(rating: String) {
    // TODO: Update to send movie rating to the watch
  }
}
