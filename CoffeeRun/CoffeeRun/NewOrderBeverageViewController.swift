//
//  NewOrderBeverageViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/5/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewOrderBeverageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    static var sizes: Array<String> = Array()
    static var beverages: Array<String> = Array()
    
    //MARK: Properties
    @IBOutlet weak var sizePicker: UIPickerView!
    @IBOutlet weak var beveragePicker: UIPickerView!
    @IBOutlet weak var detailsTextField: UITextField!
    
    
    //MARK: Actions
    @IBAction func toSeatLocation(_ sender: Any) {
        
        let selectedSize = NewOrderBeverageViewController.sizes[sizePicker.selectedRow(inComponent: 0)]
        OrderSummaryViewController.size = selectedSize
        
        let selectedBeverage = NewOrderBeverageViewController.beverages[beveragePicker.selectedRow(inComponent: 0)]
        OrderSummaryViewController.beverage = selectedBeverage
        
        OrderSummaryViewController.details = detailsTextField.text!
        
        self.performSegue(withIdentifier: "toSeatLocationSegue", sender: nil)
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
}
