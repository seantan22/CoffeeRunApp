//
//  OrderExistenceViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/6/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class OrderExistenceViewController: UIViewController {
    
    static var doesOrderExist: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
        
        getRates() {(result:Response) in
            if result.result {
                OrderSummaryViewController.deliveryFeeRate = result.response[0]
                OrderSummaryViewController.gstRate = result.response[1]
                OrderSummaryViewController.qstRate = result.response[2]
                
                DeliveredViewController.deliveryFeeRate = result.response[0]
                DeliveredViewController.gstRate = result.response[1]
                DeliveredViewController.qstRate = result.response[2]
            } else {
                print(result.response)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
          
        if OrderExistenceViewController.doesOrderExist {
                
                  self.performSegue(withIdentifier: "toExistingOrderSegue", sender: nil)
              } else {
                  self.performSegue(withIdentifier: "toNewOrderSegue", sender: nil)
              }
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
    
    //GET /getTaxRates
    func getRates(completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: URLs.URL + "getTaxRates") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var ratesResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    ratesResponse.result = jsonResponse.result
                    ratesResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(ratesResponse)
            }
        }
        task.resume()
    }
    
    
    @IBAction func unwindToOrderExistence(segue: UIStoryboardSegue) {
    }
    
}
