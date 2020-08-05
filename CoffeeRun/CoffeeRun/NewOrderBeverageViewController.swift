//
//  NewOrderBeverageViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/4/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewOrderBeverageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var vendors: Array<String> = Array()
    var beverages: Array<String> = Array()
    var sizes: Array<String> = Array()

    //MARK: Properties
    @IBOutlet weak var vendorPicker: UIPickerView!
    @IBOutlet weak var beveragePicker: UIPickerView!
    @IBOutlet weak var sizePicker: UIPickerView!
    
    //MARK: PickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
            
        case vendorPicker:
            return self.vendors.count
        
        case beveragePicker:
            return self.beverages.count

        case sizePicker:
            return self.sizes.count
    
        default:
            return 0
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,  forComponent component: Int) -> String? {
        
        switch pickerView {
            
        case vendorPicker:
            return self.vendors[row]
          
        case beveragePicker:
            return self.beverages[row]

        case sizePicker:
            return self.sizes[row]
            
        default:
            return ""
        }
        
    }
    
    
   override func viewDidLoad() {
        super.viewDidLoad()

        vendorPicker.dataSource = self
        vendorPicker.delegate = self
        beveragePicker.dataSource = self
        beveragePicker.delegate = self
        sizePicker.dataSource = self
        sizePicker.delegate = self
        
        loadPickers()
    }
    
    func loadPickers() {
        self.getVendors() {(result: Response) in
            if result.result == true {
                DispatchQueue.main.async {
                    self.vendors = result.errorMessage
                    self.vendorPicker.reloadAllComponents()
                    
                    let selectedVendor = self.vendors[self.vendorPicker.selectedRow(inComponent: 0)]
                    self.getBeverages(vendor: selectedVendor) {(result: Response) in
                        if result.result == true {
                            DispatchQueue.main.async {
                                self.beverages = result.errorMessage
                                self.beveragePicker.reloadAllComponents()
                                
                                let selectedBeverage = self.beverages[self.beveragePicker.selectedRow(inComponent: 0)]
                                self.getSizes(vendor: selectedVendor, beverage: selectedBeverage) {(result: Response) in
                                    if result.result == true {
                                        DispatchQueue.main.async {
                                            self.sizes = result.errorMessage
                                            self.sizePicker.reloadAllComponents()
                                        }
                                    } else {
                                        print("Error: Unable to get sizes.")
                                    }
                                }
                            }
                        } else {
                            print("Error: Unable to get beverages.")
                        }
                }
                }
            } else {
                print("Error: Unable to get vendors.")
            }
            
        }
    }
    
    
    
    struct Response: Decodable {
        var result: Bool
        var errorMessage: Array<String>
        init() {
            self.result = false
            self.errorMessage = Array()
        }
    }
    
    // GET /getVendors
    func getVendors(completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared

        guard let url = URL(string: "http:/localhost:5000/getVendors") else {
         print("Error: Cannot create URL")
         return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { data, response, error in
            
            var vendorsResponse: Response = Response()
            
            if let data = data {
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                        vendorsResponse.result = jsonResponse.result
                        vendorsResponse.errorMessage = jsonResponse.errorMessage
                } catch {
                    print("Error: Struct and JSON response do not match.")
                }
                completion(vendorsResponse)
            }
        }

        task.resume()
        
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

}
