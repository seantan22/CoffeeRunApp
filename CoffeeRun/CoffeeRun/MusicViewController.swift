//
//  MusicViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/17/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class MusicViewController: UIViewController {
    
    var prevZoneClicked: String = ""
    var prevFloorClicked: String = ""
    
    @IBOutlet weak var zoneAButton: UIButton!
    @IBOutlet weak var zoneBButton: UIButton!
    
    @IBOutlet weak var floorThreeButton: UIButton!
    @IBOutlet weak var floorFourButton: UIButton!
    @IBOutlet weak var floorFiveButton: UIButton!
    
    @IBAction func finishSelectingLocation(_ sender: UIBarButtonItem) {
        
            if prevFloorClicked != "" && prevZoneClicked != "" {
            performSegue(withIdentifier: "musicToSummarySegue", sender: self)
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
        default:
            print("")
            
        }
        
        
        switch sender {
            
        case zoneAButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "A"
            
        case zoneBButton:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "B"
            
        default:
            print("")
        }
        
        OrderSummaryViewController.zone = prevZoneClicked
        
    }
    
    
    @IBAction func toggleFloor(_ sender: UIButton) {
        
        switch self.prevFloorClicked {
            
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

        floorThreeButton.setTitleColor(UIColor.black, for: .normal)
        floorFourButton.setTitleColor(UIColor.black, for: .normal)
        floorFiveButton.setTitleColor(UIColor.black, for: .normal)
        
        floorThreeButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorFourButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorFiveButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
    }
    

}
