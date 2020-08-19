//
//  ExistingTripViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/7/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ExistingTripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    var checkForCompletionTimer: Timer?
    
    @IBOutlet weak var tableView: UITableView!
    
    static var ordersToPickup: [OrderWithFriends] = Array()
    
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for order in ExistingTripViewController.ordersToPickup {
            if order.status == "Delivered" {
                checkForCompletionTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(checkOrderExistence), userInfo: order.id, repeats: true)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        checkForCompletionTimer?.invalidate()
    }
    
    // Number of Cells in Table
     func numberOfSections(in tableView: UITableView) -> Int {
         return ExistingTripViewController.ordersToPickup.count
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
     }
     
     // Space between cells
     private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> Int {
         return 1
     }
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let spacer = UIView()
         spacer.backgroundColor = UIColor.white
         return spacer
     }
     
    // Cell Content
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if index < ExistingTripViewController.ordersToPickup.count {
            let order = ExistingTripViewController.ordersToPickup[indexPath.section]
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderToPickupItem", for: indexPath) as! OrderToPickupTableViewCell
                cell.setOrder(order: order)
                
                let state = ExistingTripViewController.ordersToPickup[indexPath.section].status
                       
                if state == "In Progress" {
                    cell.layer.borderColor = UIColor.systemYellow.cgColor
                } else if state == "Picked Up" {
                    cell.layer.borderColor = UIColor.systemBlue.cgColor
                } else if state == "Delivered" {
                    cell.layer.borderColor = UIColor.systemGreen.cgColor
                }
            
                index += 1
                return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Swipe Left on Cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let state = ExistingTripViewController.ordersToPickup[indexPath.section].status
        var title: String = String()
        
        if state == "In Progress" {
            title = NSLocalizedString("Mark as Picked Up", comment: "Mark as Picked Up")
        } else if state == "Picked Up" {
            title = NSLocalizedString("Mark as Delivered", comment: "Mark as Delivered")
        } else if state == "Delivered" {
            title = NSLocalizedString("Awaiting Confirmation", comment: "Awaiting Confirmation")
        }
        
        let action = UIContextualAction(style: .normal, title: title,
          handler: { (action, view, completionHandler) in
            
            if state == "In Progress" {
                self.markPickedUp(user_id: UserDefaults.standard.string(forKey: "user_id")!, order_id: ExistingTripViewController.ordersToPickup[indexPath.section].id)
                
                ExistingTripViewController.ordersToPickup[indexPath.section].status = "Picked Up"
                
            } else if state == "Picked Up" {
                self.markDelivered(user_id: UserDefaults.standard.string(forKey: "user_id")!, order_id: ExistingTripViewController.ordersToPickup[indexPath.section].id)
                
                ExistingTripViewController.ordersToPickup[indexPath.section].status = "Delivered"
                
                self.checkForCompletionTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.checkOrderExistence), userInfo: ExistingTripViewController.ordersToPickup[indexPath.section].id, repeats: true)
                
            } else if state == "Delivered" {
                print("done")
            }
        
            self.run(after: 1000) {
                self.index = 0
                tableView.reloadData()
            }
        completionHandler(true)
    })
        action.backgroundColor = UIColor.black
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }
    
    @objc func checkOrderExistence(timer: Timer) {
        let order_id = timer.userInfo as! String
        doesOrderExistForDelivery(order_id: order_id) {(result: Response) in
            if result.response[0] == "false" {
                var counter: Int = 0
                for pickupOrder in ExistingTripViewController.ordersToPickup {
                    if pickupOrder.id == order_id {
                        ExistingTripViewController.ordersToPickup.remove(at: counter)
                        self.getUpdatedFinancials(username: UserDefaults.standard.string(forKey: "username")!) {(result: Response) in
                            if result.result {
                                ProfileViewController.totalProfitMade = result.response[0]
                                ProfileViewController.balance = result.response[1]
                                self.index = 0
                                DispatchQueue.main.async {
                                   self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    counter += 1
                }
            }
            
        }
            
        if ExistingTripViewController.ordersToPickup.count == 0 {
            
            
            run(after: 1000) {
                self.performSegue(withIdentifier: "emptyTripToExistenceSegue", sender: self)
            }
            
        }
        
    }
    
    // Swipe Right on Cell
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let state = ExistingTripViewController.ordersToPickup[indexPath.section].status
        
        if state == "In Progress" {
            
            let title = NSLocalizedString("Remove", comment: "Remove")
            
            let action = UIContextualAction(style: .destructive, title: title,
              handler: { (action, view, completionHandler) in
                
                self.detachDeliveryPersonFromOrder(user_id: UserDefaults.standard.string(forKey: "user_id")!, order_id: ExistingTripViewController.ordersToPickup[indexPath.section].id)
                
                ExistingTripViewController.ordersToPickup.remove(at: indexPath.section)
                
                if ExistingTripViewController.ordersToPickup.count == 0 {
                    self.performSegue(withIdentifier: "emptyTripToExistenceSegue", sender: self)
                }
                
                self.run(after: 1000) {
                    self.index = 0
                    tableView.reloadData()
                }
                
            
            completionHandler(true)
            })
            action.backgroundColor = UIColor.systemRed
            let configuration = UISwipeActionsConfiguration(actions: [action])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
        return UISwipeActionsConfiguration()
    }
    
    func tableView(_ tableView: UITableView,
      editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCell.EditingStyle {
      return .none
    }

    //MARK: Response
    struct Response: Decodable {
     var result: Bool
     var response: Array<String>
     init() {
         self.result = false
         self.response = Array()
     }
    }
    
    // GET /doesOrderExistForDelivery
    func doesOrderExistForDelivery(order_id: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "doesOrderExistForDelivery") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(order_id, forHTTPHeaderField: "order_id")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var orderExistResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    orderExistResponse.result = jsonResponse.result
                    orderExistResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(orderExistResponse)
            }
        }
        task.resume()
    }
    
    // GET /getTotalProfit
       func getUpdatedFinancials(username: String, completion: @escaping(Response) -> ()) {
           
           let session = URLSession.shared
           
           guard let url = URL(string: testURL + "getTotalProfit") else {
               print("Error: Cannot create URL")
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.setValue(username, forHTTPHeaderField: "username")
          
           let task = session.dataTask(with: request) { data, response, error in
               if let data = data {
                   var financialsResponse = Response()
                   do {
                       let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                       financialsResponse.result = jsonResponse.result
                       financialsResponse.response = jsonResponse.response
                   } catch {
                       print(error)
                   }
                   completion(financialsResponse)
               }
           }
           task.resume()
       }
    
    
    // POST /detachDelivery
    func detachDeliveryPersonFromOrder(user_id: String, order_id: String) {

        let session = URLSession.shared

        guard let url = URL(string: testURL + "detachDelivery") else {
            print("Error: Cannot create URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonDetach = [
            "delivery_id": user_id,
            "order_id": order_id
        ]

        let dataDetach: Data
        do {
            dataDetach = try JSONSerialization.data(withJSONObject: jsonDetach, options: [] )
        } catch {
            print("Error: Unable to convert JSON to Data object")
            return
        }

        let task = session.uploadTask(with: request, from: dataDetach) { data, response, error in
            if let data = data {
                var detachResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    detachResponse.result = jsonResponse.result
                    detachResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    // POST /markPickedUp
    func markPickedUp(user_id: String, order_id: String) {

        let session = URLSession.shared

        guard let url = URL(string: testURL + "markPickedUp") else {
            print("Error: Cannot create URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonPickedUp = [
            "delivery_id": user_id,
            "order_id": order_id
        ]

        let dataPickedUp: Data
        do {
            dataPickedUp = try JSONSerialization.data(withJSONObject: jsonPickedUp, options: [] )
        } catch {
            print("Error: Unable to convert JSON to Data object")
            return
        }

        let task = session.uploadTask(with: request, from: dataPickedUp) { data, response, error in
            if let data = data {
                var pickedUpResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    pickedUpResponse.result = jsonResponse.result
                    pickedUpResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    // POST /markDelivered
    func markDelivered(user_id: String, order_id: String) {

        let session = URLSession.shared

        guard let url = URL(string: testURL + "markDelivered") else {
            print("Error: Cannot create URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonPickedUp = [
            "delivery_id": user_id,
            "order_id": order_id
        ]

        let dataPickedUp: Data
        do {
            dataPickedUp = try JSONSerialization.data(withJSONObject: jsonPickedUp, options: [] )
        } catch {
            print("Error: Unable to convert JSON to Data object")
            return
        }

        let task = session.uploadTask(with: request, from: dataPickedUp) { data, response, error in
            if let data = data {
                var pickedUpResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    pickedUpResponse.result = jsonResponse.result
                    pickedUpResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
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
