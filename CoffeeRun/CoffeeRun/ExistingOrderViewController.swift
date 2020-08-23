//
//  ExistingOrderViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/6/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ExistingOrderViewController: UIViewController {
    
    static var isCancelled: Bool = false
    
    static var gstRate: String = String()
    static var qstRate: String = String()
    static var deliveryFeeRate: String = String()
    
    static var username: String = String()
    static var orderStatus: String = String()
    static var vendor: String = String()
    static var size: String = String()
    static var beverage: String = String()
    static var details: String = String()
    static var library: String = String()
    static var floor: String = String()
    static var zone: String = String()
    static var subtotal: String = String()
    
    var statusTimer: Timer?
    
    //MARK: Properties
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var beverageLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var zoneLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var gstAmountLabel: UILabel!
    @IBOutlet weak var qstAmountLabel: UILabel!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    //MARK: Actions
    @IBAction func cancelOrderButton(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This drink won't sip itself.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.deleteOrder(username: ExistingOrderViewController.username, order_id: UserDefaults.standard.string(forKey: "order_id")!) {(result: Response) in
                if result.result {
                        ExistingOrderViewController.isCancelled = true
                }
            }
            self.statusTimer?.invalidate()
            self.run(after: 1000) {
                self.performSegue(withIdentifier: "cancelOrderToExistenceSegue", sender: nil)
            }
             
            }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        
        view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
        
        self.cancelButton.isUserInteractionEnabled = false
        self.cancelButton.isHidden = true
        
        let gstRate = Double(ExistingOrderViewController.gstRate)!
        let qstRate = Double(ExistingOrderViewController.qstRate)!
        let deliveryFeeRate = Double(ExistingOrderViewController.deliveryFeeRate)!
        
        let subtotal = Double(ExistingOrderViewController.subtotal)!
        let gstAmount = round(subtotal * gstRate * 100) / 100
        let qstAmount = round(subtotal * qstRate * 100) / 100
        let deliveryFee = (round(subtotal * deliveryFeeRate * 100) / 100) + 1.0
        let totalAmount = subtotal + gstAmount + qstAmount + deliveryFee
        
        vendorLabel.text = ExistingOrderViewController.vendor.replacingOccurrences(of: "_", with: " ")
        sizeLabel.text = ExistingOrderViewController.size
        beverageLabel.text = ExistingOrderViewController.beverage
        if ExistingOrderViewController.details == "None" {
            detailsLabel.text = ""
        } else {
            detailsLabel.text = ExistingOrderViewController.details
        }
        libraryLabel.text = ExistingOrderViewController.library
        floorLabel.text = "Floor " + ExistingOrderViewController.floor
        zoneLabel.text = "Zone " + ExistingOrderViewController.zone
        
        subtotalLabel.text = String(format: "$%.02f", subtotal)
        gstAmountLabel.text = String(format: "$%.02f", gstAmount)
        qstAmountLabel.text = String(format: "$%.02f", qstAmount)
        deliveryFeeLabel.text = String(format: "$%.02f", deliveryFee)
        totalAmountLabel.text = String(format: "$%.02f", totalAmount)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ExistingOrderViewController.isCancelled = false
        
        callGetStatus()
        
        statusTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(callGetStatus), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        statusTimer?.invalidate()
    }
    
    @objc func callGetStatus() {
        
        if ExistingOrderViewController.isCancelled {
            performSegue(withIdentifier: "cancelOrderToExistenceSegue", sender: self)
            return
        }
            
        getStatus(order_id: UserDefaults.standard.string(forKey: "order_id")!) {(result: Response) in
            DispatchQueue.main.async {
                
                if result.response[0] != "Awaiting Runner" {
                    self.cancelButton.isUserInteractionEnabled = false
                    self.cancelButton.isHidden = true
                    DeliveredViewController.delivererUsername = result.response[1]
                } else {
                    self.cancelButton.isUserInteractionEnabled = true
                    self.cancelButton.isHidden = false
                }
                
                self.statusLabel.text = result.response[0]
                
                if self.statusLabel.text == "Awaiting Runner" {
                    self.statusLabel.backgroundColor = UIColor(red: 38/255, green: 136/255, blue: 227/255, alpha: 1)
                } else if self.statusLabel.text == "In Progress" || self.statusLabel.text == "Picked Up" {
                    self.statusLabel.backgroundColor = UIColor(red: 244/255, green: 211/255, blue: 94/255, alpha: 1)
                } else if self.statusLabel.text == "Delivered" {
                    self.performSegue(withIdentifier: "toDeliveredSegue", sender: nil)
                } else if self.statusLabel.text == "Order does not exist." {
                    self.performSegue(withIdentifier: "cancelOrderToExistenceSegue", sender: nil)
                }
            }
        }
    }
    
    //MARK: StatusResponse
    struct Response: Decodable {
        var result: Bool
        var response: Array<String>
        init() {
            self.result = false
            self.response = Array()
        }
    }
    
    // GET /getOrderStatus
    func getStatus(order_id: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: URLs.URL + "getOrderStatus") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(order_id, forHTTPHeaderField: "order_id")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var statusResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    statusResponse.result = jsonResponse.result
                    statusResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(statusResponse)
            }
        }
        task.resume()
    }
    
    // POST /deleteOrder
    func deleteOrder(username: String, order_id: String, completion: @escaping(Response) -> ()) {
           
           let session = URLSession.shared

        guard let url = URL(string: URLs.URL + "deleteOrder") else {
            print("Error: Cannot create URL")
            return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "DELETE"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           let jsonLogout = [
            "username": username,
            "order_id": order_id
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
                    var deleteOrderResponse = Response()
                    do {
                        let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                        deleteOrderResponse.response = jsonResponse.response
                        print(deleteOrderResponse.response)
                    } catch {
                        print("Error: Struct and JSON response do not match.")
                    }
                    if deleteOrderResponse.result {
                       UserDefaults.standard.removeObject(forKey: "order_id")
                    }
                completion(deleteOrderResponse)
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
