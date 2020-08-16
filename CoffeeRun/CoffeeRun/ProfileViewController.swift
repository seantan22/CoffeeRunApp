//
//  ProfileViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
    }
    
    static var username: String = String()
    static var email: String = String()
    static var balance: String = String()
    static var numOfFriends: String = String()
    static var totalProfitMade: String = String()
    
    //MARK: Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    
    
    @IBAction func logoutUser(_ sender: UIBarButtonItem) {
    
        logout(user_id: UserDefaults.standard.string(forKey: "user_id")!)

        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        // Transition to Login Screen
        if UserDefaults.standard.value(forKey: "user_id") == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                .changeRootViewController(loginNavigationController)
        } else {
            return
        }
    }
    
    struct Response: Decodable {
        var result: Bool
        var response: Array<String>
        init() {
            self.result = false
            self.response = Array()
        }
    }
    
    //MARK: AOAOAOResponse
    struct AOAOAOStringsResponse: Decodable {
        var result: Bool
        var response: Array<Array<Array<String>>>
        init() {
            self.result = false
            self.response = Array()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        let balance: Double = Double(ProfileViewController.balance)!
        let profit: Double = Double(ProfileViewController.totalProfitMade)!
        
        self.usernameLabel.text = ProfileViewController.username
        self.emailLabel.text = ProfileViewController.email
        self.balanceLabel.text = String(format: "$%.02f", balance)
        self.friendsLabel.text = ProfileViewController.numOfFriends + " Friends"
        self.profitLabel.text = String(format: "$%.02f", profit)
        
        getHistory(user_id: UserDefaults.standard.value(forKey: "user_id")! as! String) {(result: AOAOAOStringsResponse) in
                OrderHistoryViewController.orderHistory = []
                PickupHistoryViewController.pickupHistory = []
                for orderIndex in result.response[0] {
                       let order = ClosedOrder(    id: orderIndex[0],
                                                   time_opened: orderIndex[1],
                                                   time_closed: orderIndex[2],
                                                   payer: orderIndex[3],
                                                   payee: orderIndex[4],
                                                   finalPrice: orderIndex[5],
                                                   rating: orderIndex[6],
                                                   size: orderIndex[7],
                                                   beverage: orderIndex[8],
                                                   vendor: orderIndex[9])

                   OrderHistoryViewController.orderHistory.append(order)
                }
                for orderIndex in result.response[1] {
                       let order = ClosedOrder(    id: orderIndex[0],
                                                   time_opened: orderIndex[1],
                                                   time_closed: orderIndex[2],
                                                   payer: orderIndex[3],
                                                   payee: orderIndex[4],
                                                   finalPrice: orderIndex[5],
                                                   rating: orderIndex[6],
                                                   size: orderIndex[7],
                                                   beverage: orderIndex[8],
                                                   vendor: orderIndex[9])

                   PickupHistoryViewController.pickupHistory.append(order)
                }
        }
    }
    
    // POST /logout
    func logout(user_id: String) {
        
        let session = URLSession.shared

        guard let url = URL(string: testURL + "logout") else {
         print("Error: Cannot create URL")
         return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonLogout = [
         "user_id": user_id
        ]

        let dataLogout: Data
        do {
         dataLogout = try JSONSerialization.data(withJSONObject: jsonLogout, options: [] )
        } catch {
         print("Error: Unable to convert JSON to Data object")
         return
        }

        let task = session.uploadTask(with: request, from: dataLogout) { data, response, error in
            if let data = data {
                    var logoutResponse = Response()
                 do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    logoutResponse.response = jsonResponse.response
                    print(logoutResponse.response)
                 } catch {
                     print("Error: Struct and JSON response do not match.")
                 }
                 if logoutResponse.result {
                    UserDefaults.standard.removeObject(forKey: "user_id")
                 }
            }
        }

        task.resume()
    }
    
    // GET /getOrderHistory
    func getHistory(user_id: String, completion: @escaping(AOAOAOStringsResponse) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "getClosedOrdersByUser") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(user_id, forHTTPHeaderField: "user_id")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var orderHistoryResponse = AOAOAOStringsResponse()
                do {
                    let jsonResponse = try JSONDecoder().decode(AOAOAOStringsResponse.self, from: data)
                    orderHistoryResponse.result = jsonResponse.result
                    orderHistoryResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(orderHistoryResponse)
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
