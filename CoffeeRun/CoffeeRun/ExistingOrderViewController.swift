//
//  ExistingOrderViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/6/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ExistingOrderViewController: UIViewController {
    
    static var orderStatus: String = String()
    
    //MARK: Properties
    @IBOutlet weak var statusLabel: UILabel!
    
    var statusTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetStatus()
        
        statusTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(callGetStatus), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        statusTimer?.invalidate()
    }
    
    @objc func callGetStatus() {
        getStatus(order_id: UserDefaults.standard.string(forKey: "order_id")!) {(result: StatusResponse) in
            DispatchQueue.main.async {
                
                self.statusLabel.text = result.response[0]
                
                if self.statusLabel.text == "Awaiting Runner" {
                    self.statusLabel.backgroundColor = UIColor.blue
                } else if self.statusLabel.text == "In Progress" || self.statusLabel.text == "Picked Up" {
                    self.statusLabel.backgroundColor = UIColor.yellow
                } else if self.statusLabel.text == "Delivered" {
                    self.performSegue(withIdentifier: "toDeliveredSegue", sender: nil)
                }
            }
        }
    }
    
    //MARK: StatusResponse
    struct StatusResponse: Decodable {
        var result: Bool
        var response: Array<String>
        init() {
            self.result = false
            self.response = Array()
        }
    }
    
    // GET /getOrderStatus
    func getStatus(order_id: String, completion: @escaping(StatusResponse) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: "http:/localhost:5000/getOrderStatus") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(order_id, forHTTPHeaderField: "order_id")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var statusResponse = StatusResponse()
                do {
                    let jsonResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
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

}
