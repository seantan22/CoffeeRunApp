//
//  NewOrderBeverageViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/5/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewOrderBeverageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    static var sizes: Array<String> = Array()
    static var beverages: Array<String> = Array()
    
    //MARK: Properties
    @IBOutlet weak var sizePicker: UIPickerView!
    @IBOutlet weak var beveragePicker: UIPickerView!
    @IBOutlet weak var detailsTextField: UITextField!
    
    
    //MARK: Actions
   
    @IBAction func toSeatLocation(_ sender: UIBarButtonItem) {
        
        sender.isEnabled = false
        
        let selectedSize = NewOrderBeverageViewController.sizes[sizePicker.selectedRow(inComponent: 0)]
        OrderSummaryViewController.size = selectedSize
        
        let selectedBeverage = NewOrderBeverageViewController.beverages[beveragePicker.selectedRow(inComponent: 0)]
        OrderSummaryViewController.beverage = selectedBeverage
        
        if detailsTextField.text! == "" {
            OrderSummaryViewController.details = "None"
        } else {
            OrderSummaryViewController.details = detailsTextField.text!
        }
        
        
        self.getLibraryInfo() {(result: Response) in
            if result.result {
                DispatchQueue.main.async {
                    
                    SeatLocationViewController.allLibraryInfo = result.response
                    
                    let array = Array(result.response[0].keys)
                    SeatLocationViewController.libraries = array
                    
                    let innerArray = result.response[0][array[0]]!
                    SeatLocationViewController.floors = innerArray["Floor"]!
                    SeatLocationViewController.zones = innerArray["Zone"]!
                }
            }
        }
        
        self.getBeverageSubtotal(vendor: OrderSummaryViewController.vendor, beverage: OrderSummaryViewController.beverage, size: OrderSummaryViewController.size) {(result: BevPriceResponse) in
            if result.result {
                DispatchQueue.main.async {
                    OrderSummaryViewController.subtotal = result.response[0]
                }
                self.run(after: 1000) {
                    self.performSegue(withIdentifier: "toSeatLocationSegue", sender: nil)
                    sender.isEnabled = true
                }
            } else {
                print("Error: You can't get this beverage in that size.")
            }
        }
    
    }
    
    //MARK: PickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
            
        case sizePicker:
            return NewOrderBeverageViewController.sizes.count
            
        case beveragePicker:
            return NewOrderBeverageViewController.beverages.count
    
        default:
            return 0
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,  forComponent component: Int) -> String? {
          
          switch pickerView {
              
          case sizePicker:
            return NewOrderBeverageViewController.sizes[row]
              
          case beveragePicker:
            return NewOrderBeverageViewController.beverages[row]
            
          default:
              return ""
          }
          
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        sizePicker.dataSource = self
        sizePicker.delegate = self
        beveragePicker.dataSource = self
        beveragePicker.delegate = self

     }
    
    struct Response: Decodable {
        var result: Bool
        var response: Array<[String: [String: Array<String>]]>
        init() {
            self.result = false
            self.response = Array()
        }
    }
    
    struct BevPriceResponse: Decodable {
        var result: Bool
        var response: Array<String>
        init() {
            self.result = false
            self.response = Array()
        }
    }

    
    // GET /getLibraryInformation
    func getLibraryInfo(completion: @escaping(Response) -> ()) {
           
        let session = URLSession.shared

        guard let url = URL(string: testURL + "getLibraryInformation") else {
            print("Error: Cannot create URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = session.dataTask(with: request) { data, response, error in
            var librariesResponse: Response = Response()
            if let data = data {
               do {
                   let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                   librariesResponse.result = jsonResponse.result
                   librariesResponse.response = jsonResponse.response
               } catch {
                   print(error)
               }
               completion(librariesResponse)
            }
        }
        task.resume()
    }
    
    // GET /getPriceOfBeverage
    func getBeverageSubtotal(vendor: String, beverage: String, size: String, completion: @escaping(BevPriceResponse) -> ()) {
           
        let session = URLSession.shared

        guard let url = URL(string: testURL + "getPriceOfBeverage") else {
            print("Error: Cannot create URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(vendor, forHTTPHeaderField: "vendor")
        request.setValue(beverage, forHTTPHeaderField: "beverage")
        request.setValue(size, forHTTPHeaderField: "size")

        let task = session.dataTask(with: request) { data, response, error in
            var bevPriceResponse: BevPriceResponse = BevPriceResponse()
            if let data = data {
               do {
                   let jsonResponse = try JSONDecoder().decode(BevPriceResponse.self, from: data)
                   bevPriceResponse.result = jsonResponse.result
                   bevPriceResponse.response = jsonResponse.response
               } catch {
                   print(error)
               }
               completion(bevPriceResponse)
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
