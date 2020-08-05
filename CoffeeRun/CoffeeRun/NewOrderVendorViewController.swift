//
//  NewOrderBeverageViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/4/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewOrderVendorViewController: UIViewController {
    
    var vendors: Array<String> = Array()

    @IBAction func selectTimHortons(_ sender: UIButton) {
        let selectedVendor = "Tim Hortons"
        self.getBeverages(vendor: selectedVendor) {(result: Response) in
            if result.result == true {
                DispatchQueue.main.async {
                   NewOrderBeverageViewController.beverages = result.errorMessage
                }
            }
        }
        run(after: 750) {
            self.performSegue(withIdentifier: "toBevSegue", sender: nil)
        }
    }
    
    @IBAction func selectPM(_ sender: UIButton) {
       let selectedVendor = "Premiere Moisson"
        self.getBeverages(vendor: selectedVendor) {(result: Response) in
            if result.result == true {
                DispatchQueue.main.async {
                   NewOrderBeverageViewController.beverages = result.errorMessage
                }
            }
        }
        run(after: 750) {
            self.performSegue(withIdentifier: "toBevSegue", sender: nil)
        }
    }
    
    @IBAction func selectSecondCup(_ sender: UIButton) {
        let selectedVendor = "Second Cup"
        self.getBeverages(vendor: selectedVendor) {(result: Response) in
            if result.result == true {
                DispatchQueue.main.async {
                   NewOrderBeverageViewController.beverages = result.errorMessage
                }
            }
        }
        run(after: 750) {
            self.performSegue(withIdentifier: "toBevSegue", sender: nil)
        }
    }
    
    @IBAction func selectStarbucks(_ sender: UIButton) {
        let selectedVendor = "Starbucks"
        self.getBeverages(vendor: selectedVendor) {(result: Response) in
            if result.result == true {
                DispatchQueue.main.async {
                   NewOrderBeverageViewController.beverages = result.errorMessage
                }
            }
        }
        run(after: 750) {
            self.performSegue(withIdentifier: "toBevSegue", sender: nil)
        }
    }
    
    
   override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    struct Response: Decodable {
        var result: Bool
        var errorMessage: Array<String>
        init() {
            self.result = false
            self.errorMessage = Array()
        }
    }
    
    // GET /getBeverages
    func getBeverages(vendor: String, completion: @escaping(Response) -> ()) {
           
           let session = URLSession.shared

           guard let url = URL(string: "http:/localhost:5000/getBeverages") else {
            print("Error: Cannot create URL")
            return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(vendor, forHTTPHeaderField: "vendor")
           
           let task = session.dataTask(with: request) { data, response, error in
               
               var beveragesResponse: Response = Response()
               
               if let data = data {
                   do {
                       let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                           beveragesResponse.result = jsonResponse.result
                           beveragesResponse.errorMessage = jsonResponse.errorMessage
                   } catch {
                       print("Error: Struct and JSON response do not match.")
                   }
                   completion(beveragesResponse)
               }
           }

           task.resume()
           
       }
    
    // GET /getBeverages
    func getSizes(vendor: String, beverage: String, completion: @escaping(Response) -> ()) {
           
        let session = URLSession.shared

        guard let url = URL(string: "http:/localhost:5000/getSize") else {
            print("Error: Cannot create URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(vendor, forHTTPHeaderField: "vendor")
        request.setValue(beverage, forHTTPHeaderField: "beverage")

        let task = session.dataTask(with: request) { data, response, error in
           
           var sizesResponse: Response = Response()
           
           if let data = data {
               do {
                   let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                       sizesResponse.result = jsonResponse.result
                       sizesResponse.errorMessage = jsonResponse.errorMessage
               } catch {
                   print("Error: Struct and JSON response do not match.")
               }
               completion(sizesResponse)
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
