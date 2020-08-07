//
//  TripExistenceViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/7/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class TripExistenceViewController: UIViewController {
    
    static var doesTripExist: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
          if TripExistenceViewController.doesTripExist {
                  self.performSegue(withIdentifier: "toExistingTripSegue", sender: nil)
              } else {
            
                getNumberOfOpenOrders() {(result: OpenOrdersResponse) in
                    NewTripViewController.numOpenOrders = result.response
                }
                    
                  self.performSegue(withIdentifier: "toNewTripSegue", sender: nil)
              }
    }
    
    
    //MARK: OpenOrdersResponse
    struct OpenOrdersResponse: Decodable {
        var result: Bool
        var response: String
        init() {
            self.result = false
            self.response = String()
        }
    }
    
    // GET /getNumberOfAllOpenOrders
    func getNumberOfOpenOrders(completion: @escaping(OpenOrdersResponse) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: "http:/localhost:5000/getNumberOfAllOpenOrders") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var openOrdersResponse = OpenOrdersResponse()
                do {
                    let jsonResponse = try JSONDecoder().decode(OpenOrdersResponse.self, from: data)
                    openOrdersResponse.result = jsonResponse.result
                    openOrdersResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(openOrdersResponse)
            }
        }
        task.resume()
    }
    
    

}
