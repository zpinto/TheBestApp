//
//  SquareClient.swift
//  TheBestApp
//
//  Created by Zachary Pinto on 3/7/20.
//  Copyright © 2020 Zachary Pinto. All rights reserved.
//

import Foundation
import MapKit

class SquareClient {
    static var CLIENT_ID = ""
    static var CLIENT_SECRET = ""
    
    static var AUTH_QUERY_STRING = ""
    static let BASE_URL = "https://api.foursquare.com/v2/venues"
    static let SEARCH_ENDPOINT = "\(SquareClient.BASE_URL)/explore?"
    
    static func initialize(clientId: String, clientSecret: String) {
        SquareClient.CLIENT_ID = clientId
        SquareClient.CLIENT_SECRET = clientSecret
        
        SquareClient.AUTH_QUERY_STRING = "client_id=\(SquareClient.CLIENT_ID)&client_secret=\(SquareClient.CLIENT_SECRET)&v=20141020&"
    }
    
    static func fetchCategories(location: CLLocation, radius: CLLocationDistance, price: Int, closure: @escaping ([NSDictionary]) -> Void) {
        let queryParams = SquareClient.AUTH_QUERY_STRING + "ll=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=\(Int(radius))&openNow=1&section=food&llAcc=1&price=\(price + 1)"
        
        
//        "ll=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=\(Int(radius))&query=restaurant"


        let url = URL(string: SquareClient.SEARCH_ENDPOINT + queryParams.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
       
        let request = URLRequest(url: url)

        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
//                            NSLog("response: \(responseDictionary)")
                        let group = (responseDictionary.value(forKeyPath: "response.groups") as! [NSDictionary])[0]
                        let restaurantsArray = group.value(forKey: "items") as! [NSDictionary]
                        
                        var restaurants = [NSDictionary]()
                        for restaurant in restaurantsArray {
                            restaurants.append(restaurant.value(forKey: "venue") as! NSDictionary)
                        }
                        
                        var categoriesSet : Dictionary = Dictionary<String, Any>()
                        for restaurant in restaurants {
                            
                            let categories = restaurant.value(forKeyPath: "categories")
                            
                            for category in categories as! [NSDictionary] {
                                categoriesSet[category.value(forKey: "id") as! String] = category
                            }
                        }
                        
                        
                        var categoriesList = [NSDictionary]()
                        for (_, category) in categoriesSet {
                            categoriesList.append(category as! NSDictionary)
                        }
                        
                        closure(categoriesList)
                    }
                }
        });
        task.resume()
    }
    
    static func fetchRestaurants(location: CLLocation, radius: CLLocationDistance, price: Int, categories: NSArray, closure: @escaping ([NSDictionary]) -> Void) {
        
        var queryParams = SquareClient.AUTH_QUERY_STRING + "ll=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=\(Int(radius))&openNow=1&section=food&price=\(price + 1)&llAcc=1&categoryId="
        
        for category in categories {
            queryParams += category as! String + ","
        }

        let url = URL(string: SquareClient.SEARCH_ENDPOINT + queryParams.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        
        
        let request = URLRequest(url: url)

        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        let group = (responseDictionary.value(forKeyPath: "response.groups") as! [NSDictionary])[0]
                        let restaurantsArray = group.value(forKey: "items") as! [NSDictionary]
                        
                        var restaurants = [NSDictionary]()
                        for restaurant in restaurantsArray {
                            restaurants.append(restaurant.value(forKey: "venue") as! NSDictionary)
                        }
                        
                        closure(restaurants)
                    }
                }
        });
        task.resume()
    }
    
    
    static func fetchRestaurantInfo(restaurantId: String, closure: @escaping (NSDictionary?) -> Void) {
        
        let url = URL(string: SquareClient.BASE_URL + "/\(restaurantId)?" + SquareClient.AUTH_QUERY_STRING.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        
        let request = URLRequest(url: url)

        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        
                        
                        let restaurant = responseDictionary.value(forKeyPath: "response.venue") as? NSDictionary
                        closure(restaurant)
                    }
                }
        });
        task.resume()
    }
}
