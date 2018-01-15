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

import Siesta

class YelpAPI {

  static let sharedInstance = YelpAPI()
  
  private let service = Service(baseURL: "https://api.yelp.com/v3", standardTransformers: [.text, .image])

  fileprivate init() {
    
    LogCategory.enabled = [.network, .pipeline, .observers]

    service.configure("**") {
      $0.headers["Authorization"] =
      "Bearer B6sOjKGis75zALWPa7d2dNiNzIefNbLGGoF75oANINOL80AUhB1DjzmaNzbpzF-b55X-nG2RUgSylwcr_UYZdAQNvimDsFqkkhmvzk6P8Qj0yXOQXmMWgTD_G7ksWnYx"
      $0.expirationTime = 60 * 60
    }

    let jsonDecoder = JSONDecoder()

    service.configureTransformer("/businesses/*") {
      try jsonDecoder.decode(RestaurantDetails.self, from: $0.content)
    }

    service.configureTransformer("/businesses/search") {
      try jsonDecoder.decode(SearchResults<Restaurant>.self, from: $0.content).businesses
    }
  }

  func restaurantList(for location: String) -> Resource {
    return service
      .resource("/businesses/search")
      .withParam("term", "pizza")
      .withParam("location", location)
  }

  func restaurantDetails(_ id: String) -> Resource {
    return service
      .resource("/businesses")
      .child(id)
  }
}
