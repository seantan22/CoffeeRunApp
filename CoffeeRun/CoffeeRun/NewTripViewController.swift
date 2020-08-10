//
//  RunViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewTripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    var ordersTimer: Timer?
    
    var orders: [Order] = []
    
    var tempOrders: [Order] = []
    
    let myRefreshControl = UIRefreshControl()
    
    var index: Int = 0
    
    /** OVERALL PAGE VIEW **/
    
    static var numOpenOrders: String = String()

    //MARK: Properties
    @IBOutlet weak var availableOrdersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(NewTripViewController.handleRefresh), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

    }
    
    @objc func handleRefresh() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.availableOrdersLabel.text = NewTripViewController.numOpenOrders
        ordersTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(callGetOrders), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ordersTimer?.invalidate()
    }
    
    @objc func callGetOrders() {
        orders = populateArray()
    }
    
    
    /** ORDERS ARRAY SETUP **/
    
    //TODO: get orders, iterate through with for loop
    func populateArray() -> [Order] {
        
        getOrders() {(result: Response) in
            if result.result {
                NewTripViewController.numOpenOrders = String(result.response.count)
                DispatchQueue.main.async {
                    self.availableOrdersLabel.text = NewTripViewController.numOpenOrders
                }
                self.index = 0
                self.tempOrders = []
                for orderIndex in result.response {
                   let order = Order(restaurant: orderIndex["restaurant"]!,
                                           size: orderIndex["size"]!,
                                           beverage: orderIndex["beverage"]!,
                                           details: orderIndex["details"]!,
                                           time: orderIndex["time"]!,
                                           library: orderIndex["library"]!,
                                           floor: orderIndex["floor"]!,
                                           zone: orderIndex["segment"]!,
                                           creator: orderIndex["creator"]!)
                    self.tempOrders.append(order)
                }
   
            } else {
                print("Error: Unable to retrieve order(s).")
            }
        }
        
        self.tableView.reloadData()
        return tempOrders
    }
    
    
    /** TABLE VIEW **/
    
        @IBOutlet weak var tableView: UITableView!
       
       // Number of Cells in Table
       func numberOfSections(in tableView: UITableView) -> Int {
           return orders.count
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
       }
    
        private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> Int {
            return 1
        }
    
        // Space between cells
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let spacer = UIView()
            spacer.backgroundColor = UIColor.white
            return spacer
        }
    
       // Cell Content
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let order = self.orders[index]
               let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItem", for: indexPath) as! PickupOrdersTableViewCell
                cell.setOrder(order: order)
                index += 1
        print(index)
               return cell
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
    func getOrders(completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "getOrders") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
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
