//
//  ConfirmSelectionViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/11/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ConfirmSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    static var selectedOrders: Array<Order> = Array()

    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    @IBOutlet weak var selectedOrdersLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var estProfitLabel: UILabel!
    
    //MARK: Actions
    @IBAction func startTripButton(_ sender: UIBarButtonItem) {
        
        TripExistenceViewController.doesTripExist = true
        
        for order in ConfirmSelectionViewController.selectedOrders {
            attachDeliveryPersonToOrder(user_id: UserDefaults.standard.string(forKey: "user_id")!, order_id: order.id) {(result: Response) in
                if result.result {
                    print(result.response[0])
                }
            }
        }
        
        run(after: 1000) {
            self.performSegue(withIdentifier: "confirmTripToCurrentTripSegue", sender: self)
        }

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        selectedOrdersLabel.text = "You've selected " + String(ConfirmSelectionViewController.selectedOrders.count) + " orders:"
        
        var totalCost: Double = 0.0
        
        for order in ConfirmSelectionViewController.selectedOrders {
            totalCost += Double(order.cost)!
        }
        
        totalCostLabel.text = "Total Order Cost: $" + String(round(totalCost * 100) / 100)
        
        estProfitLabel.text = "Your Estimated Profit is $" + String(round(totalCost * 0.15 * 100) / 100) + "."

    }
    
    // Number of Cells in Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return ConfirmSelectionViewController.selectedOrders.count
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
        
        let order = ConfirmSelectionViewController.selectedOrders[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedOrderItem", for: indexPath) as! SelectedOrderTableViewCell
            cell.setOrder(order: order)
            return cell
   }
    
    struct Response: Decodable {
      var result: Bool
      var response: Array<String>
      init() {
          self.result = false
          self.response = Array()
      }
    }
    
    // POST /attachDelivery
    func attachDeliveryPersonToOrder(user_id: String, order_id: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "attachDelivery") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonLogin = [
            "delivery_id": user_id,
            "order_id": order_id
        ]
        
        let dataLogin: Data
        do {
            dataLogin = try JSONSerialization.data(withJSONObject: jsonLogin, options: [] )
        } catch {
            print("Error: Unable to convert JSON to Data object")
            return
        }
       
        let task = session.uploadTask(with: request, from: dataLogin) { data, response, error in
            if let data = data {
                var attachResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    attachResponse.result = jsonResponse.result
                    attachResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(attachResponse)
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
