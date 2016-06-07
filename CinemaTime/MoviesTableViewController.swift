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

class MoviesTableViewController: UITableViewController {
  
  lazy var dataSource: NSArray = TicketOffice.sharedInstance.movies
  
  // MARK: - UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let section = dataSource[section] as? NSDictionary,
      let moviesInSection = section["movies"] as? NSArray {
        return moviesInSection.count
    }
    return 0
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let sectionDictionary = dataSource[section] as? NSDictionary,
      let time = sectionDictionary["time"] as? String {
        return time
    }
    return ""
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MovieTableViewCell
    if let movie = movieForIndexPath(indexPath) {
      cell.movie = movie
    }
    return cell
  }
  
  private func movieForIndexPath(indexPath: NSIndexPath) -> Movie? {
    if let section = dataSource[indexPath.section] as? NSDictionary,
      let moviesInSection = section["movies"] as? NSArray,
      let movie = moviesInSection[indexPath.row] as? NSDictionary,
      let sectionDictionary = dataSource[indexPath.section] as? NSDictionary,
      let time = sectionDictionary["time"] as? String  {
        return Movie(dictionary: movie, time: time)
    }
    return nil
  }
  
  // MARK: - Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SegueMovieDetail",
      let indexPath = tableView.indexPathForSelectedRow,
      let cell = tableView.cellForRowAtIndexPath(indexPath) as? MovieTableViewCell,
      let movie = cell.movie,
      let destination = segue.destinationViewController as? MovieDetailViewController {
          destination.movie = movie
    }
  }
  
}

