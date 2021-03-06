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

import WatchKit
import WatchConnectivity

let NotificationPurchasedMovieOnWatch = "PurchasedMovieOnWatch"

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
  
  lazy var documentsDirectory: String = {
      return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
    }()
  
  lazy var notificationCenter: NSNotificationCenter = {
    return NSNotificationCenter.defaultCenter()
    }()
  
  func applicationDidFinishLaunching() {
    setupWatchConnectivity()
    setupNotificationCenter()
  }
  
  // MARK: - Notification Center
  
  private func setupNotificationCenter() {
    notificationCenter.addObserverForName(NotificationPurchasedMovieOnWatch, object: nil, queue: nil) { (notification:NSNotification) -> Void in
      self.sendPurchasedMoviesToPhone(notification)
    }
  }
  
  private func sendPurchasedMoviesToPhone(notification:NSNotification) {
    // TODO: Update to send purchased movies to phone
    
    if WCSession.isSupported() {
      
      if let movies = TicketOffice.sharedInstance.purchasedMovieTicketIDs()  {
        do {
          let dictionary = ["movies": movies]
          try WCSession.defaultSession().updateApplicationContext(dictionary)
        } catch {
                print("ERROR: \(error)")
              }
          }
        }
  }
  
  // MARK: - Watch Connectivity
  
  private func setupWatchConnectivity() {
    // TODO: Update to set up watch connectivity
    if WCSession.isSupported() {
      let session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }
  }
  
  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    
    if let movies = applicationContext["movies"] as? [String] {
      
      TicketOffice.sharedInstance.purchaseTicketsForMovies(movies)
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        WKInterfaceController.reloadRootControllersWithNames(["PurchaseMovieTickets"], contexts: nil)
    }
  }
}
  
  func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
    
    if let movieID = userInfo["movie_id"] as? String,
      let rating = userInfo["rating"] as? String {
      TicketOffice.sharedInstance.rateMovie(movieID, rating: rating)
    }
  }
}
