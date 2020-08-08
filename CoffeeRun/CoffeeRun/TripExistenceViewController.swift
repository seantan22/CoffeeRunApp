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
        
        checkIfOrderExist(user_id: UserDefaults.standard.string(forKey: "user_id")!) {(result: OrderExistenceResponse) in
        
            OrderExistenceViewController.doesOrderExist = result.result
            DispatchQueue.main.async {
                if OrderExistenceViewController.doesOrderExist {
                    self.performSegue(withIdentifier: "toTripDenySegue", sender: nil)
                } else {
                    if TripExistenceViewController.doesTripExist {
                      self.performSegue(withIdentifier: "toExistingTripSegue", sender: nil)
                    } else {
                        self.getNumberOfOpenOrders() {(result: OpenOrdersResponse) in
                            NewTripViewController.numOpenOrders = result.response
                        }
                        self.run(after: 1000) {
                            self.performSegue(withIdentifier: "toNewTripSegue", sender: nil)
                        }
                    }
                }
            }
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
    
    //MARK: OrderExistenceResponse
    struct OrderExistenceResponse: Decodable {
        var result: Bool
        var response: Array<[String: String]>
        init() {
            self.result = false
            self.response = Array()
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
    
    // GET /getOrderByUser
    func checkIfOrderExist(user_id: String, completion: @escaping(OrderExistenceResponse) -> ()) {
        
        let session = URLSession.shared
         
         guard let url = URL(string: "http:/localhost:5000/getOrderByUser") else {
             print("Error: Cannot create URL")
             return
         }
         
         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.setValue(user_id, forHTTPHeaderField: "user_id")
        
         let task = session.dataTask(with: request) { data, response, error in
             if let data = data {
                 var orderExistenceResponse = OrderExistenceResponse()
                 do {
                     let jsonResponse = try JSONDecoder().decode(OrderExistenceResponse.self, from: data)
                     orderExistenceResponse.result = jsonResponse.result
                     orderExistenceResponse.response = jsonResponse.response
                 } catch {
                     print(error)
                 }
                if orderExistenceResponse.result {
                    UserDefaults.standard.set(orderExistenceResponse.response[0]["_id"]!, forKey: "order_id")
                }
                 completion(orderExistenceResponse)
             }
         }
         task.resume()
    }
    
    func run(after milliseconds: Int, completion: @escaping() -> Void) {
        let deadline = DispatchTime.now() + .milliseconds(milliseconds)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion()
        }
    }
    
}
