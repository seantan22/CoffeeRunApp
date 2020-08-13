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
    
    @IBOutlet weak var tableView: UITableView!
    
    static var ordersToPickup: [Order] = Array()
    
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(ExistingTripViewController.ordersToPickup)
        
        tableView.delegate = self
        tableView.dataSource = self

        self.navigationItem.setHidesBackButton(true, animated: true)
        
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
    
    // Swipe Left on Cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let state = ExistingTripViewController.ordersToPickup[indexPath.section].status
        var title: String = String()
        
        if state == "In Progress" {
            title = NSLocalizedString("Mark as Picked Up", comment: "Mark as Picked Up")
        } else if state == "Picked Up" {
            title = NSLocalizedString("Mark as Delivered", comment: "Mark as Delivered")
        } else if state == "Delivered" {
            title = NSLocalizedString("Delivered", comment: "Delivered")
        }
        
        let action = UIContextualAction(style: .normal, title: title,
          handler: { (action, view, completionHandler) in
            
            if state == "In Progress" {
                self.markPickedUp(user_id: UserDefaults.standard.string(forKey: "user_id")!, order_id: ExistingTripViewController.ordersToPickup[indexPath.section].id)
                
                ExistingTripViewController.ordersToPickup[indexPath.section].status = "Picked Up"
                
            } else if state == "Picked Up" {
                self.markDelivered(user_id: UserDefaults.standard.string(forKey: "user_id")!, order_id: ExistingTripViewController.ordersToPickup[indexPath.section].id)
                
                ExistingTripViewController.ordersToPickup[indexPath.section].status = "Delivered"
                
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
