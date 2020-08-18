//
//  SeatLocationViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/5/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class McLennanViewController: UIViewController {
    
    var prevZoneClicked: String = ""
    var prevFloorClicked: String = ""
    
    //MARK: Properties
    @IBOutlet weak var zoneAButton: UIButton!
    @IBOutlet weak var zoneBButton: UIButton!
    @IBOutlet weak var zoneCButton: UIButton!
    @IBOutlet weak var zoneDButton: UIButton!
    @IBOutlet weak var zoneEButton: UIButton!
    @IBOutlet weak var zoneFButton: UIButton!
    @IBOutlet weak var zoneGButton: UIButton!
    @IBOutlet weak var zoneHButton: UIButton!
    @IBOutlet weak var zoneIButton: UIButton!
    
    @IBOutlet weak var floorTwoButton: UIButton!
    @IBOutlet weak var floorThreeButton: UIButton!
    @IBOutlet weak var floorFiveButton: UIButton!
    @IBOutlet weak var floorSixButton: UIButton!
    
    @IBAction func finishSelectingLibrary(_ sender: Any) {
        
        if prevFloorClicked != "" && prevZoneClicked != "" {
            performSegue(withIdentifier: "mclennanToSummarySegue", sender: self)
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
        case "H":
            zoneHButton.backgroundColor = UIColor.clear
        case "I":
            zoneIButton.backgroundColor = UIColor.clear
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
            
        case zoneHButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "H"
            
        case zoneIButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "I"
            
        default:
            print("default")
        }
        
        OrderSummaryViewController.zone = prevZoneClicked
    }
    
    @IBAction func toggleFloor(_ sender: UIButton) {
        
        switch self.prevFloorClicked {
            
        case "2":
            floorTwoButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            floorTwoButton.setTitleColor(UIColor.black, for: .normal)
        case "3":
            floorThreeButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            floorThreeButton.setTitleColor(UIColor.black, for: .normal)
        case "5":
            floorFiveButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            floorFiveButton.setTitleColor(UIColor.black, for: .normal)
        case "6":
            floorSixButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            floorSixButton.setTitleColor(UIColor.black, for: .normal)
        default:
            print("")
            
        }
        
        switch sender {
            
        case floorTwoButton:
            sender.backgroundColor = UIColor.black
            floorTwoButton.setTitleColor(UIColor.white, for: .normal)
            self.prevFloorClicked = "2"
            
        case floorThreeButton:
            sender.backgroundColor = UIColor.black
            floorThreeButton.setTitleColor(UIColor.white, for: .normal)
            self.prevFloorClicked = "3"
            
        case floorFiveButton:
            sender.backgroundColor = UIColor.black
            floorFiveButton.setTitleColor(UIColor.white, for: .normal)
            self.prevFloorClicked = "5"
            
        case floorSixButton:
            sender.backgroundColor = UIColor.black
            floorSixButton.setTitleColor(UIColor.white, for: .normal)
            self.prevFloorClicked = "6"
            
        default:
            print("")
        }
        
        OrderSummaryViewController.floor = prevFloorClicked
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        floorTwoButton.setTitleColor(UIColor.black, for: .normal)
        floorThreeButton.setTitleColor(UIColor.black, for: .normal)
        floorFiveButton.setTitleColor(UIColor.black, for: .normal)
        floorSixButton.setTitleColor(UIColor.black, for: .normal)
        
        floorTwoButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorThreeButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorFiveButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorSixButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
    }


}
