//
//  TripExistenceViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/7/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class TripExistenceViewController: UIViewController {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    static var doesTripExist: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
        
    }
    
    @IBAction func unwindToTripExistence(segue: UIStoryboardSegue) {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkIfOrderExists(user_id: UserDefaults.standard.string(forKey: "user_id")!) {(result: ExistenceResponse) in
        
            OrderExistenceViewController.doesOrderExist = result.result
            
            DispatchQueue.main.async {
                if OrderExistenceViewController.doesOrderExist {
                    self.performSegue(withIdentifier: "toTripDenySegue", sender: nil)
                } else {
                    
                    TripExistenceViewController.doesTripExist = false
                    
                    self.checkIfTripExists(user_id: UserDefaults.standard.string(forKey: "user_id")!) {(result: ExistenceResponse) in
                           
                        if result.response.count != 0 {
                            print(result.response)
                            TripExistenceViewController.doesTripExist = result.result
                            ExistingTripViewController.ordersToPickup = []
                            for orderIndex in result.response {
                                    let order = OrderWithFriends(   id: orderIndex["_id"]!,
                                                                    restaurant: orderIndex["restaurant"]!,
                                                                    size: orderIndex["size"]!,
                                                                    beverage: orderIndex["beverage"]!,
                                                                    details: orderIndex["details"]!,
                                                                    time: orderIndex["time"]!,
                                                                    library: orderIndex["library"]!,
                                                                    floor: orderIndex["floor"]!,
                                                                    zone: orderIndex["segment"]!,
                                                                    creator: orderIndex["creator"]!,
                                                                    cost: orderIndex["cost"]!,
                                                                    status: orderIndex["status"]!,
                                                                    delivery_boy: orderIndex["delivery_boy"]!,
                                                                    friends: orderIndex["friends"]!)
                                
                                ExistingTripViewController.ordersToPickup.append(order)
                            }
                    
                        }
                    
                        DispatchQueue.main.async {
                            if TripExistenceViewController.doesTripExist {
                                self.run(after: 1000) {
                                    self.performSegue(withIdentifier: "toExistingTripSegue", sender: nil)
                                }
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
    
    //MARK: ExistenceResponse
    struct ExistenceResponse: Decodable {
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
        
        guard let url = URL(string: testURL + "getNumberOfAllOpenOrders") else {
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
    func checkIfOrderExists(user_id: String, completion: @escaping(ExistenceResponse) -> ()) {
        
        let session = URLSession.shared
         
         guard let url = URL(string: testURL + "getOrderByUser") else {
             print("Error: Cannot create URL")
             return
         }
         
         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.setValue(user_id, forHTTPHeaderField: "user_id")
        
         let task = session.dataTask(with: request) { data, response, error in
             if let data = data {
                 var orderExistenceResponse = ExistenceResponse()
                 do {
                     let jsonResponse = try JSONDecoder().decode(ExistenceResponse.self, from: data)
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
    
    // GET /getOrderDelivery
    func checkIfTripExists(user_id: String, completion: @escaping(ExistenceResponse) -> ()) {
        
        let session = URLSession.shared
         
         guard let url = URL(string: testURL + "getOrderDelivery") else {
             print("Error: Cannot create URL")
             return
         }
         
         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.setValue(user_id, forHTTPHeaderField: "user_id")
        
         let task = session.dataTask(with: request) { data, response, error in
             if let data = data {
                 var tripExistenceResponse = ExistenceResponse()
                 do {
                     let jsonResponse = try JSONDecoder().decode(ExistenceResponse.self, from: data)
                     tripExistenceResponse.result = jsonResponse.result
                     tripExistenceResponse.response = jsonResponse.response
                 } catch {
                     print(error)
                 }
                 completion(tripExistenceResponse)
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
