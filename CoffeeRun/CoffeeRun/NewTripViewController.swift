//
//  RunViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewTripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var ordersTimer: Timer?
    
    var orders: [OrderWithFriends] = Array()
    
    var tempOrders: [OrderWithFriends] = Array()
    
    var clearChosenCell: Int = -1
    
    var previousOrderCount: Int = 0
    
    var index: Int = 0
    
    var selectedOrders: [OrderWithFriends] = Array()
    
    @IBOutlet weak var availableOrdersView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Actions
    @IBAction func clickSelectButton(_ sender: UIBarButtonItem) {
        if self.selectedOrders.count > 0 {
            ConfirmSelectionViewController.selectedOrders = self.selectedOrders
            
            self.performSegue(withIdentifier: "toConfirmSelectionSegue", sender: self)
        } else {
            print("Please select an order.")
        }
    }
    
    /** OVERALL PAGE VIEW **/
    
    static var numOpenOrders: String = String()
    static var prevOrderCount: String = "0"

    //MARK: Properties
    @IBOutlet weak var availableOrdersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
        
        availableOrdersView.card()
        
        tableView.backgroundColor = UIColor.clear
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.availableOrdersLabel.text = NewTripViewController.numOpenOrders
        ordersTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(callGetOrders), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ordersTimer?.invalidate()
    }
    
    @objc func callGetOrders() {
        orders = populateArray()
    }
    
    //TODO: get orders, iterate through with for loop
    func populateArray() -> [OrderWithFriends] {
        getOrders(username: UserDefaults.standard.string(forKey: "username")!) {(result: Response) in
            if result.result {
                NewTripViewController.numOpenOrders = String(result.response.count)
                DispatchQueue.main.async {
                    self.availableOrdersLabel.text = NewTripViewController.numOpenOrders
                }
                self.index = 0
                
                print(self.selectedOrders.count)
                
                self.previousOrderCount = self.tempOrders.count
                self.tempOrders = []
                
                for orderIndex in result.response {
                        let order = OrderWithFriends(  id: orderIndex["_id"]!,
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
                    self.tempOrders.append(order)
                }
   
            } else {
                print("Error: Unable to retrieve order(s).")
            }
        }
        self.tableView.reloadData()
        
        if (self.previousOrderCount != self.tempOrders.count){
            // First, check if deleted item was highlighted
            if (self.selectedOrders.count != 0 && self.tempOrders.count < self.previousOrderCount){
            
                // Find the deleted order
                for selectedOrder in self.selectedOrders {
                    
                    if !self.checkIfSelected(array: self.tempOrders, order: selectedOrder) {
                       
                        // If deleted order was selected, get rid of it
                        self.selectedOrders.remove(at: self.getOrderIndex(array: self.selectedOrders, order: selectedOrder))
                        
                    }
                }
            }
        }
        
        return tempOrders
    }
    
    
    /** TABLE VIEW **/
    
       // Number of Cells in Table
       func numberOfSections(in tableView: UITableView) -> Int {
           return orders.count
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
       }
    
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 10.0
        }
    
        // Space between cells
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let spacer = UIView()
            spacer.backgroundColor = UIColor.clear
            return spacer
        }
    
       // Cell Content
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            if index < orders.count {
                let order = self.orders[index]
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItem", for: indexPath) as! PickupOrdersTableViewCell
                cell.setOrder(order: order)
                
                let starImage = UIImage(systemName: "star.fill")
                let starView = UIImageView(image: starImage)
                
                // Each loop, check to make sure that if cell is chosen, it actually exists in selectedorders
                if cell.contentView.backgroundColor == Colors.selectBlue {
                    // It should exist in selectedOrders
                    if !self.checkIfSelected(array: self.selectedOrders, order: order){
                        cell.contentView.backgroundColor = UIColor.white
                    }
                }
                
                // Check to make sure the cell is in selectedOrders
                if self.checkIfSelected(array: self.selectedOrders, order: order) {
                    if cell.contentView.backgroundColor == UIColor.white{
                        cell.contentView.backgroundColor = Colors.selectBlue
                    }
                }
                
                if order.friends == "true" {
                    cell.accessoryView = starView
                }
                
                index += 1
                return cell
            }
            return UITableViewCell()
       }
    

    
    // Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
                UIView.animate(withDuration: 0.3, animations: {
                    if cell.contentView.backgroundColor == Colors.selectBlue {
                        cell.contentView.backgroundColor = UIColor.white
                        let selectedOrder = self.orders[indexPath.section]
                        if self.checkIfSelected(array: self.selectedOrders, order: selectedOrder) {
                            self.selectedOrders.remove(at: self.getOrderIndex(array: self.selectedOrders, order: selectedOrder))
                        }
                    } else {
                         if self.selectedOrders.count < 3 {
                            cell.contentView.backgroundColor = Colors.selectBlue
                            let selectedOrder = self.orders[indexPath.section]
                            if !self.checkIfSelected(array: self.selectedOrders, order: selectedOrder) {
                                self.selectedOrders = self.selectedOrders + [selectedOrder]
                            }
                        } else {
                            print("You can only select 3 orders max.")
                        }
                    }
                })
        }
    }
    
    func checkIfSelected(array: [OrderWithFriends], order: OrderWithFriends) -> Bool {
        for specificOrder in array {
            if specificOrder.creator == order.creator {
                return true
            }
        }
        return false
    }
    
    func getOrderIndex(array: [OrderWithFriends], order: OrderWithFriends) -> Int {
        var counter: Int = 0
        for specificOrder in array {
            if specificOrder.creator == order.creator {
                return counter
            }
            counter += 1
        }
        return 0
    }
    
    /** API REQUESTS **/
    
    //MARK: Response
    struct Response: Decodable {
        var result: Bool
        var response: Array<[String: String]>
        init() {
            self.result = false
            self.response = Array()
        }
    }
    
    // GET /getOrders
    func getOrders(username: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: URLs.URL + "getOrders") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(username, forHTTPHeaderField: "username")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var ordersResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    ordersResponse.result = jsonResponse.result
                    ordersResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(ordersResponse)
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
