//
//  NewOrderBeverageViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/5/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewOrderBeverageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    static var vendor: String = String()
    static var beverages: Array<String> = Array()
    
    //MARK: Properties
    @IBOutlet weak var beveragePicker: UIPickerView!
    
    //MARK: PickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
            
        case beveragePicker:
            return NewOrderBeverageViewController.beverages.count
    
        default:
            return 0
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,  forComponent component: Int) -> String? {
          
          switch pickerView {
              
          case beveragePicker:
              return NewOrderBeverageViewController.beverages[row]
              
          default:
              return ""
          }
          
      }
    
    override func viewDidLoad() {
         super.viewDidLoad()
         
         beveragePicker.dataSource = self
         beveragePicker.delegate = self

     }
}
