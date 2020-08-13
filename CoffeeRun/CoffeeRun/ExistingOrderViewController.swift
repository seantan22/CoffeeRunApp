//
//  ExistingOrderViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/6/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ExistingOrderViewController: UIViewController {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    static var username: String = String()
    static var orderStatus: String = String()
    var statusTimer: Timer?
    
    //MARK: Properties
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    //MARK: Actions
    @IBAction func cancelOrderButton(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This drink won't sip itself.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.deleteOrder(username: ExistingOrderViewController.username, order_id: UserDefaults.standard.string(forKey: "order_id")!)
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
        
        cancelButton.isUserInteractionEnabled = true
        cancelButton.isHidden = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetStatus()
        
        statusTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(callGetStatus), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        statusTimer?.invalidate()
    }
    
    @objc func callGetStatus() {
        
        getStatus(order_id: UserDefaults.standard.string(forKey: "order_id")!) {(result: Response) in
            DispatchQueue.main.async {
                
                if result.response[0] != "Awaiting Runner" {
                            self.cancelButton.isUserInteractionEnabled = false
                            self.cancelButton.isHidden = true
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
        
        guard let url = URL(string: testURL + "getOrderStatus") else {
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
    func deleteOrder(username: String, order_id: String) {
           
           let session = URLSession.shared

           guard let url = URL(string: testURL + "deleteOrder") else {
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
