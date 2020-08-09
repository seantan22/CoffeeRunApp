//
//  NewOrderBeverageViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/4/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewOrderVendorViewController: UIViewController {
    
    var testURL = "http:/localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    //MARK: Properties
    @IBOutlet weak var timHortonsBtn: UIButton!
    @IBOutlet weak var pmBtn: UIButton!
    @IBOutlet weak var secondCupBtn: UIButton!
    @IBOutlet weak var starbucksBtn: UIButton!
    
    //MARK: Actions
    @IBAction func selectTimHortons(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pmBtn.isUserInteractionEnabled = false
        secondCupBtn.isUserInteractionEnabled = false
        starbucksBtn.isUserInteractionEnabled = false
        let selectedVendor = "Tim_Hortons"
        self.getBeverageInfo(vendor: selectedVendor) {(result: Response) in
            if result.result {
                DispatchQueue.main.async {
                    NewOrderBeverageViewController.beverages = result.response[0]
                    NewOrderBeverageViewController.sizes = result.response[1]
                }
            }
        }
        OrderSummaryViewController.vendor = selectedVendor
        run(after: 1000) {
            self.performSegue(withIdentifier: "toBevSegue", sender: nil)
            sender.isUserInteractionEnabled = true
            self.pmBtn.isUserInteractionEnabled = true
            self.secondCupBtn.isUserInteractionEnabled = true
            self.starbucksBtn.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func selectPM(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        timHortonsBtn.isUserInteractionEnabled = false
        secondCupBtn.isUserInteractionEnabled = false
        starbucksBtn.isUserInteractionEnabled = false
       let selectedVendor = "Premiere_Moisson"
        self.getBeverageInfo(vendor: selectedVendor) {(result: Response) in
            if result.result {
                DispatchQueue.main.async {
                   NewOrderBeverageViewController.beverages = result.response[0]
                   NewOrderBeverageViewController.sizes = result.response[1]
                }
            }
        }
        OrderSummaryViewController.vendor = selectedVendor
        run(after: 1000) {
            self.performSegue(withIdentifier: "toBevSegue", sender: nil)
            sender.isUserInteractionEnabled = true
            self.timHortonsBtn.isUserInteractionEnabled = true
            self.secondCupBtn.isUserInteractionEnabled = true
            self.starbucksBtn.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func selectSecondCup(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        timHortonsBtn.isUserInteractionEnabled = false
        pmBtn.isUserInteractionEnabled = false
        starbucksBtn.isUserInteractionEnabled = false
        let selectedVendor = "Second_Cup"
        self.getBeverageInfo(vendor: selectedVendor) {(result: Response) in
            if result.result {
                DispatchQueue.main.async {
                   NewOrderBeverageViewController.beverages = result.response[0]
                   NewOrderBeverageViewController.sizes = result.response[1]
                }
            }
        }
        OrderSummaryViewController.vendor = selectedVendor
        run(after: 1000) {
            self.performSegue(withIdentifier: "toBevSegue", sender: nil)
            sender.isUserInteractionEnabled = true
            self.timHortonsBtn.isUserInteractionEnabled = true
            self.pmBtn.isUserInteractionEnabled = true
            self.starbucksBtn.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func selectStarbucks(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        timHortonsBtn.isUserInteractionEnabled = false
        pmBtn.isUserInteractionEnabled = false
        secondCupBtn.isUserInteractionEnabled = false
        let selectedVendor = "Starbucks"
        self.getBeverageInfo(vendor: selectedVendor) {(result: Response) in
            if result.result {
                DispatchQueue.main.async {
                   NewOrderBeverageViewController.beverages = result.response[0]
                   NewOrderBeverageViewController.sizes = result.response[1]
                }
            }
        }
        OrderSummaryViewController.vendor = selectedVendor
        run(after: 1000) {
            self.performSegue(withIdentifier: "toBevSegue", sender: nil)
            sender.isUserInteractionEnabled = true
            self.timHortonsBtn.isUserInteractionEnabled = true
            self.pmBtn.isUserInteractionEnabled = true
            self.secondCupBtn.isUserInteractionEnabled = true
        }
    }
    
    
   override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    struct Response: Decodable {
        var result: Bool
        var response: Array<Array<String>>
        init() {
            self.result = false
            self.response = Array(Array())
        }
    }
    
    // GET /getBeverages
    func getBeverageInfo(vendor: String, completion: @escaping(Response) -> ()) {
           
        let session = URLSession.shared

        guard let url = URL(string: testURL + "getBeverageInfo") else {
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
                   beveragesResponse.response = jsonResponse.response
               } catch {
                   print(error)
               }
               completion(beveragesResponse)
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
