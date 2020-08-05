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

    //MARK: Properties
    @IBOutlet weak var vendorPicker: UIPickerView!
    
    //MARK: PickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.vendors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,  forComponent component: Int) -> String? {
        return self.vendors[row]
    }
    
    
   override func viewDidLoad() {
        super.viewDidLoad()

        vendorPicker.dataSource = self
        vendorPicker.delegate = self
        
        self.getVendors() {(result: VendorsResponse) in
            if result.result == true {
                DispatchQueue.main.async {
                    self.vendors = result.errorMessage
                    self.vendorPicker.reloadAllComponents()
                }
            } else {
                print("Error: Unable to get vendors.")
            }
            
        }
        
    }
    
    struct VendorsResponse: Decodable {
        var result: Bool
        var errorMessage: Array<String>
        init() {
            self.result = false
            self.errorMessage = Array()
        }
    }
    
    // GET /getVendors
    func getVendors(completion: @escaping(VendorsResponse) -> ()) {
        
        let session = URLSession.shared

        guard let url = URL(string: "http:/localhost:5000/getVendors") else {
         print("Error: Cannot create URL")
         return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { data, response, error in
            
            var vendorsResponse: VendorsResponse = VendorsResponse()
            
            if let data = data {
                do {
                    let jsonResponse = try JSONDecoder().decode(VendorsResponse.self, from: data)
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
    


}
