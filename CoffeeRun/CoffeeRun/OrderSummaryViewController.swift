//
//  OrderSummaryViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/5/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class OrderSummaryViewController: UIViewController {

    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    static var vendor: String = String()
    static var beverage: String = String()
    static var size: String = String()
    static var details: String = String()
    static var library: String = String()
    static var floor: String = String()
    static var zone: String = String()
    static var subtotal: String = String()
    
    //MARK: Properties
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var beverageLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var zoneLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    
    //MARK: Actions
    @IBAction func clickPlaceOrder(_ sender: UIBarButtonItem) {
        
        self.errorMsgLabel.text = "Placing order..."
        
        createOrder(restaurant: OrderSummaryViewController.vendor,
                    beverage: OrderSummaryViewController.beverage,
                    size: OrderSummaryViewController.size,
                    details: OrderSummaryViewController.details,
                    library: OrderSummaryViewController.library,
                    floor: OrderSummaryViewController.floor,
                    segment: OrderSummaryViewController.zone,
                    cost: OrderSummaryViewController.subtotal,
                    user_id: UserDefaults.standard.string(forKey: "user_id")!) {(result: Response) in
                        
            if result.result {
                self.run(after: 1000) {
                    self.performSegue(withIdentifier: "toOrderPlacedSegue", sender: nil)
                }
            } else {
                DispatchQueue.main.async {
                     self.errorMsgLabel.text = result.response[0]
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vendorLabel.text = OrderSummaryViewController.vendor.replacingOccurrences(of: "_", with: " ")
        sizeLabel.text = OrderSummaryViewController.size
        beverageLabel.text = OrderSummaryViewController.beverage
        if OrderSummaryViewController.details == "None" {
            detailsLabel.text = ""
        } else {
            detailsLabel.text = OrderSummaryViewController.details
        }
        libraryLabel.text = OrderSummaryViewController.library
        floorLabel.text = "Floor " + OrderSummaryViewController.floor
        zoneLabel.text = "Zone " + OrderSummaryViewController.zone
        subtotalLabel.text = "$" + OrderSummaryViewController.subtotal
        
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
    
    // POST /createOrder
    func createOrder(restaurant: String,
                     beverage: String,
                     size: String,
                     details: String,
                     library: String,
                     floor: String,
                     segment: String,
                     cost: String,
                     user_id: String,
                     completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: deployedURL + "createOrder") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonLogin = [
            "restaurant": restaurant,
            "beverage": beverage,
            "size": size,
            "details": details,
            "library": library,
            "floor": floor,
            "segment": segment,
            "cost": cost,
            "user_id": user_id
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
                var createOrderResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    createOrderResponse.result = jsonResponse.result
                    createOrderResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                if createOrderResponse.result {
                    UserDefaults.standard.set(createOrderResponse.response[0], forKey: "order_id")
                }
                completion(createOrderResponse)
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
