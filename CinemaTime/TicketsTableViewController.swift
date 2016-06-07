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

class TicketsTableViewController: UITableViewController {
  
  var dataSource = [Movie]()
  lazy var notificationCenter: NSNotificationCenter = {
    return NSNotificationCenter.defaultCenter()
    }()
  var notificationObserver: NSObjectProtocol?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    notificationObserver = notificationCenter.addObserverForName(NotificaitonPurchasedMovieOnWatch, object: nil, queue: nil) { (notification:NSNotification) -> Void in
      self.updateDisplay()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.updateDisplay()
  }
  
  private func updateDisplay() {
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      if let movies = TicketOffice.sharedInstance.purchasedMovies() {
        self.dataSource = movies
        self.tableView.reloadData()
      }
    }
  }
  
  deinit {
    if let observer = notificationObserver {
      notificationCenter.removeObserver(observer)
    }
  }
  
  // MARK: - UITableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CellPurchasedMovie", forIndexPath: indexPath) as! MovieTableViewCell
    let movie = dataSource[indexPath.row]
    cell.movie = movie
    return cell
  }
  
  // MARK: - Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SeguePurchasedToMovieDetail",
      let indexPath = tableView.indexPathForSelectedRow,
      let cell = tableView.cellForRowAtIndexPath(indexPath) as? MovieTableViewCell,
      let movie = cell.movie,
      let destination = segue.destinationViewController as? MovieDetailViewController {
        destination.movie = movie
    }
  }
  
}
