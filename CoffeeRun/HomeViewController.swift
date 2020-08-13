//
//  HomeViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITabBarControllerDelegate {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    // Prevents double click on tab bar
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController;
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
    
    //MARK: ArrayOfStringsResponse
    struct ArrayOfStringsResponse: Decodable {
        var result: Bool
        var response: Array<String>
        init() {
            self.result = false
            self.response = Array()
        }
    }
    
    //MARK: AOAOResponse
    struct AOAOStringsResponse: Decodable {
        var result: Bool
        var response: Array<Array<String>>
        init() {
            self.result = false
            self.response = Array(Array())
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
         tabBarController?.delegate = self
        
        checkIfOrderExist(user_id: UserDefaults.standard.string(forKey: "user_id")!) {(result: OrderExistenceResponse) in
            
            OrderExistenceViewController.doesOrderExist = result.result
            
            if result.result {
                ExistingOrderViewController.orderStatus = result.response[0]["status"]!
                DeliveredViewController.subtotal = result.response[0]["cost"]!
            }
            
        }
        
        loadProfile(user_id: UserDefaults.standard.string(forKey: "user_id")!) {(result: ArrayOfStringsResponse) in
            if result.result {
                    ProfileViewController.username = result.response[0]
                    ExistingOrderViewController.username = result.response[0]
                    ProfileViewController.email = result.response[1]
                    ProfileViewController.balance = result.response[2]
            } else {
                print(result.response[0])
            }
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getFriends(username: UserDefaults.standard.string(forKey: "username")!) {(result: AOAOStringsResponse) in
            if result.result {
                ProfileViewController.numOfFriends = String(result.response.count)
            }
        }
        
        self.getAllUsersExceptSelf(username: UserDefaults.standard.string(forKey: "username")!) {(result: AOAOStringsResponse) in
            if result.result {
                FindUsersViewController.users = result.response
                FindUsersViewController.subUsers = result.response
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController == tabBarController.viewControllers?[2] {
            let pickupVC = tabBarController.viewControllers?[2] as! UINavigationController
            pickupVC.popToRootViewController(animated: false)
        }
    }
    
    // GET /getUser
    func loadProfile(user_id: String, completion: @escaping(ArrayOfStringsResponse) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "getUser") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(user_id, forHTTPHeaderField: "user_id")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var profileResponse = ArrayOfStringsResponse()
                do {
                    let jsonResponse = try JSONDecoder().decode(ArrayOfStringsResponse.self, from: data)
                    profileResponse.result = jsonResponse.result
                    profileResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(profileResponse)
            }
        }
        task.resume()
    }
    
    // GET /getOrderByUser
    func checkIfOrderExist(user_id: String, completion: @escaping(OrderExistenceResponse) -> ()) {
        
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
    
    
    // GET /getAllFriends
    func getFriends(username: String, completion: @escaping(AOAOStringsResponse) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "getAllFriends") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(username, forHTTPHeaderField: "user")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var friendsResponse = AOAOStringsResponse()
                do {
                    let jsonResponse = try JSONDecoder().decode(AOAOStringsResponse.self, from: data)
                    friendsResponse.result = jsonResponse.result
                    friendsResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(friendsResponse)
            }
        }
        task.resume()
    }
    
    // GET /getUsers
    func getAllUsersExceptSelf(username: String, completion: @escaping(AOAOStringsResponse) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "getUsers") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(username, forHTTPHeaderField: "username")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var usersResponse = AOAOStringsResponse()
                do {
                    let jsonResponse = try JSONDecoder().decode(AOAOStringsResponse.self, from: data)
                    usersResponse.result = jsonResponse.result
                    usersResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(usersResponse)
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
