//
//  SeatLocationViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/5/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class SeatLocationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    static var allLibraryInfo: Array<[String: [String: Array<String>]]> = Array()
    static var libraries: Array<String> = Array()
    static var floors: Array<String> = Array()
    static var zones: Array<String> = Array()
    
    //MARK: Properties
    @IBOutlet weak var libraryPicker: UIPickerView!
    @IBOutlet weak var floorPicker: UIPickerView!
    @IBOutlet weak var zonePicker: UIPickerView!
    
    //MARK: Actions
    @IBAction func toOrderSummary(_ sender: UIBarButtonItem) {
        
        let selectedLibrary = SeatLocationViewController.libraries[libraryPicker.selectedRow(inComponent: 0)]
        OrderSummaryViewController.library = selectedLibrary
        
        let selectedFloor = SeatLocationViewController.floors[floorPicker.selectedRow(inComponent: 0)]
        OrderSummaryViewController.floor = selectedFloor
        
        let selectedZone = SeatLocationViewController.zones[zonePicker.selectedRow(inComponent: 0)]
        OrderSummaryViewController.zone = selectedZone
        
        self.performSegue(withIdentifier: "toOrderSummarySegue", sender: nil)
    }
    
    //MARK: PickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
            
        case libraryPicker:
            return SeatLocationViewController.libraries.count
            
        case floorPicker:
            return SeatLocationViewController.floors.count
        
        case zonePicker:
            return SeatLocationViewController.zones.count
    
        default:
            return 0
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,  forComponent component: Int) -> String? {
          
          switch pickerView {
              
          case libraryPicker:
            return SeatLocationViewController.libraries[row]
              
          case floorPicker:
            return SeatLocationViewController.floors[row]
        
          case zonePicker:
            return SeatLocationViewController.zones[row]
            
          default:
              return ""
          }
          
      }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                
        let array = Array(SeatLocationViewController.allLibraryInfo[0].keys)
        
        let innerArray = SeatLocationViewController.allLibraryInfo[0][array[row]]!
        SeatLocationViewController.floors = innerArray["Floor"]!
        SeatLocationViewController.zones = innerArray["Zone"]!
        
        floorPicker.reloadAllComponents()
        zonePicker.reloadAllComponents()
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryPicker.dataSource = self
        libraryPicker.delegate = self
        floorPicker.dataSource = self
        floorPicker.delegate = self
        zonePicker.dataSource = self
        zonePicker.delegate = self
        
    }


}
