/// Copyright (c) 2017 Razeware LLC
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

class RestaurantListViewController: UIViewController {

  static let locations = ["Atlanta", "Boston", "Chicago", "Los Angeles", "New York", "San Francisco"]

  @IBOutlet weak var tableView: UITableView!

  private var restaurants: [Restaurant] = [] {
    didSet {
      tableView.reloadData()
    }
  }

  var currentLocation: String! {
    didSet {
      restaurantListResource = YelpAPI.sharedInstance.restaurantList(for: currentLocation)
    }
  }

  var restaurantListResource: Resource? {
    didSet {
      oldValue?.removeObservers(ownedBy: self)

      restaurantListResource?
        .addObserver(self)
        .addObserver(statusOverlay, owner: self)
        .loadIfNeeded()
    }
  }

  private var statusOverlay = ResourceStatusOverlay()

  override func viewDidLoad() {
    super.viewDidLoad()
    currentLocation = RestaurantListViewController.locations.first!
    tableView.register(RestaurantListTableViewCell.nib,
                       forCellReuseIdentifier: "RestaurantListTableViewCell")
    statusOverlay.embed(in: self)
  }

  override func viewDidLayoutSubviews() {
    statusOverlay.positionToCoverParent()
  }
}

// MARK: - ResourceObserver
extension RestaurantListViewController: ResourceObserver {
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantListTableViewCell",
                                             for: indexPath) as! RestaurantListTableViewCell

    guard indexPath.row <= restaurants.count else {
      return cell
    }

    let restaurant = restaurants[indexPath.row]
    cell.nameLabel.text = restaurant.name
    cell.iconImageView.imageURL = restaurant.imageUrl
    return cell
  }
}

extension RestaurantListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = RestaurantListTableViewHeader()
    headerView.delegate = self
    headerView.location = currentLocation
    return headerView
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row <= restaurants.count else {
      return
    }

    let detailsViewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "RestaurantDetailsViewController") as! RestaurantDetailsViewController
    detailsViewController.restaurantId = restaurants[indexPath.row].id
    navigationController?.pushViewController(detailsViewController, animated: true)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - RestaurantListTableViewHeaderDelegate
extension RestaurantListViewController: RestaurantListTableViewHeaderDelegate {
  func didTapHeaderButton(_ headerView: RestaurantListTableViewHeader) {
    let locationPicker = UIAlertController(title: "Select location", message: nil, preferredStyle: .actionSheet)
    for location in RestaurantListViewController.locations {
      locationPicker.addAction(UIAlertAction(title: location, style: .default) { [weak self] action in
        guard let strongSelf = self else { return }
        strongSelf.currentLocation = action.title
        strongSelf.tableView.reloadData()
      })
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    locationPicker.addAction(cancelAction)
    present(locationPicker, animated: true)
  }
}

