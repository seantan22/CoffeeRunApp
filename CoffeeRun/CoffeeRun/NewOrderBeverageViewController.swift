//
//  NewOrderBeverageViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/5/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewOrderBeverageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    static var sizes: Array<String> = Array()
    static var beverages: Array<String> = Array()
    
    //MARK: Properties
    @IBOutlet weak var sizePicker: UIPickerView!
    @IBOutlet weak var beveragePicker: UIPickerView!
    @IBOutlet weak var detailsTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var sizeSection: UIView!
    @IBOutlet weak var bevSection: UIView!
    
    //MARK: Actions
   
    @IBAction func toSeatLocation(_ sender: UIBarButtonItem) {
        
        sender.isEnabled = false
        
        errorLabel.text = ""
        
        let selectedSize = NewOrderBeverageViewController.sizes[sizePicker.selectedRow(inComponent: 0)]
        OrderSummaryViewController.size = selectedSize
        
        let selectedBeverage = NewOrderBeverageViewController.beverages[beveragePicker.selectedRow(inComponent: 0)]
        OrderSummaryViewController.beverage = selectedBeverage
        
        if detailsTextField.text! == "" {
            OrderSummaryViewController.details = "None"
        } else {
            OrderSummaryViewController.details = detailsTextField.text!
        }
        
        self.getBeverageSubtotal(vendor: OrderSummaryViewController.vendor, beverage: OrderSummaryViewController.beverage, size: OrderSummaryViewController.size) {(result: BevPriceResponse) in
            if result.result {
                DispatchQueue.main.async {
                    OrderSummaryViewController.subtotal = result.response[0]
                }
                self.run(after: 1000) {
                    self.performSegue(withIdentifier: "toLibrarySelectionSegue", sender: nil)
                    sender.isEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "You can't get this beverage in that size."
                }
                self.run(after: 500) {
                    sender.isEnabled = true
                }
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
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        50
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        
        pickerLabel.textColor = UIColor.black
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.light)
        
        switch pickerView {
            
                case sizePicker:
                      pickerLabel.text = NewOrderBeverageViewController.sizes[row]
                      return pickerLabel
        
                case beveragePicker:
                    pickerLabel.text = NewOrderBeverageViewController.beverages[row]
                    return pickerLabel
        
                default:
                    return pickerLabel
                }
        
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        sizePicker.dataSource = self
        sizePicker.delegate = self
        beveragePicker.dataSource = self
        beveragePicker.delegate = self
        
        view.setGradientBackground(colorA: Colors.lightBlue, colorB: Colors.lightPurple)
        beveragePicker.backgroundColor = UIColor.clear
        sizePicker.backgroundColor = UIColor.clear
        detailsTextField.styleTextInput()
        
        sizeSection.card()
        bevSection.card()
        
        self.errorLabel.text = ""
    
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
    
    // GET /getPriceOfBeverage
    func getBeverageSubtotal(vendor: String, beverage: String, size: String, completion: @escaping(BevPriceResponse) -> ()) {
           
        let session = URLSession.shared

        guard let url = URL(string: URLs.URL + "getPriceOfBeverage") else {
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
