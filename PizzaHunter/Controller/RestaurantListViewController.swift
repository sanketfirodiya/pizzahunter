///// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Siesta

class RestaurantListViewController: UIViewController, ResourceObserver {

  @IBOutlet weak var tableView: UITableView!
  private var restaurants: [Restaurant] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  private var statusOverlay = ResourceStatusOverlay()

  override func viewDidLoad() {
    super.viewDidLoad()

    YelpAPI.sharedInstance.restaurantsList()
      .addObserver(self)
      .addObserver(statusOverlay, owner: self)
      .loadIfNeeded()

    statusOverlay.embed(in: self)
  }

  override func viewDidLayoutSubviews() {
    statusOverlay.positionToCoverParent()
  }

  func resourceChanged(_ resource: Resource, event: ResourceEvent) {
    restaurants = resource.typedContent() ?? []
  }
}

// MARK: - UITableViewDataSource
extension RestaurantListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return restaurants.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantListCell", for: indexPath)

    guard indexPath.row <= restaurants.count else {
      return cell
    }

    let restaurant = restaurants[indexPath.row]

    if let imageView = cell.viewWithTag(1) as? RemoteImageView {
      imageView.imageURL = restaurant.imageUrl
    }

    if let nameLabel = cell.viewWithTag(2) as? UILabel {
      nameLabel.text = restaurant.name
    }

    return cell
  }
}

// MARK: - UITableViewDelegate
extension RestaurantListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row <= restaurants.count else {
      return
    }

    let detailsViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RestaurantDetailsViewController") as! RestaurantDetailsViewController
    detailsViewController.restaurantId = restaurants[indexPath.row].id
    navigationController?.pushViewController(detailsViewController, animated: true)

    tableView.deselectRow(at: indexPath, animated: true)
  }
}
