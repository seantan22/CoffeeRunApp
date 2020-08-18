//
//  LawViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/17/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class LawViewController: UIViewController {
    
    var prevZoneClicked: String = ""
    var prevFloorClicked: String = ""
    
    @IBOutlet weak var zoneAButton: UIButton!
    @IBOutlet weak var zoneBButton: UIButton!
    @IBOutlet weak var zoneCButton: UIButton!
    @IBOutlet weak var zoneDButton: UIButton!
    @IBOutlet weak var zoneEButton: UIButton!
    @IBOutlet weak var zoneFButton: UIButton!
    @IBOutlet weak var zoneGButton: UIButton!
    
    @IBOutlet weak var floorOneButton: UIButton!
    @IBOutlet weak var floorTwoButton: UIButton!
    @IBOutlet weak var floorThreeButton: UIButton!
    @IBOutlet weak var floorFourButton: UIButton!
    @IBOutlet weak var floorFiveButton: UIButton!
    
    @IBAction func finishSelectingLocation(_ sender: UIBarButtonItem) {
        
        if prevFloorClicked != "" && prevZoneClicked != "" {
            performSegue(withIdentifier: "lawToSummarySegue", sender: self)
        } else {
            print("Please select a floor & zone.")
        }
    }
    
    @IBAction func toggleZone(_ sender: UIButton) {
        
        switch self.prevZoneClicked {
            
        case "A":
            zoneAButton.backgroundColor = UIColor.clear
        case "B":
            zoneBButton.backgroundColor = UIColor.clear
        case "C":
            zoneCButton.backgroundColor = UIColor.clear
        case "D":
            zoneDButton.backgroundColor = UIColor.clear
        case "E":
            zoneEButton.backgroundColor = UIColor.clear
        case "F":
            zoneFButton.backgroundColor = UIColor.clear
        case "G":
            zoneGButton.backgroundColor = UIColor.clear
        default:
            print("default")
            
        }
        
        
        switch sender {
            
        case zoneAButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "A"
            
        case zoneBButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "B"
            
        case zoneCButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "C"
            
        case zoneDButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "D"
            
        case zoneEButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "E"
            
        case zoneFButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "F"

        case zoneGButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "G"
            
        default:
            print("default")
        }
        
        OrderSummaryViewController.zone = prevZoneClicked
        
    }
    
    @IBAction func toggleFloor(_ sender: UIButton) {
    
        switch self.prevFloorClicked {
            
        case "1":
            floorOneButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            floorOneButton.setTitleColor(UIColor.black, for: .normal)
        case "2":
            floorTwoButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            floorTwoButton.setTitleColor(UIColor.black, for: .normal)
        case "3":
            floorThreeButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            floorThreeButton.setTitleColor(UIColor.black, for: .normal)
        case "4":
            floorFourButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            floorFourButton.setTitleColor(UIColor.black, for: .normal)
        case "5":
            floorFiveButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            floorFiveButton.setTitleColor(UIColor.black, for: .normal)
        
        default:
            print("")
            
        }
        
        switch sender {
            
        case floorOneButton:
            sender.backgroundColor = UIColor.black
            floorOneButton.setTitleColor(UIColor.white, for: .normal)
            self.prevFloorClicked = "1"
            
        case floorTwoButton:
            sender.backgroundColor = UIColor.black
            floorTwoButton.setTitleColor(UIColor.white, for: .normal)
            self.prevFloorClicked = "2"
            
        case floorThreeButton:
            sender.backgroundColor = UIColor.black
            floorThreeButton.setTitleColor(UIColor.white, for: .normal)
            self.prevFloorClicked = "3"
        
        case floorFourButton:
            sender.backgroundColor = UIColor.black
            floorFourButton.setTitleColor(UIColor.white, for: .normal)
            self.prevFloorClicked = "4"
            
        case floorFiveButton:
            sender.backgroundColor = UIColor.black
            floorFiveButton.setTitleColor(UIColor.white, for: .normal)
            self.prevFloorClicked = "5"
        
        default:
            print("")
        }
        
        OrderSummaryViewController.floor = prevFloorClicked
        
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        floorOneButton.setTitleColor(UIColor.black, for: .normal)
        floorTwoButton.setTitleColor(UIColor.black, for: .normal)
        floorThreeButton.setTitleColor(UIColor.black, for: .normal)
        floorFourButton.setTitleColor(UIColor.black, for: .normal)
        floorFiveButton.setTitleColor(UIColor.black, for: .normal)
        
        floorOneButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorTwoButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorThreeButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorFourButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorFiveButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        

    }
    

}
