//
//  RedpathViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/17/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class RedpathViewController: UIViewController {

    var prevZoneClicked: String = ""
    var prevFloorClicked: String = ""
    
    @IBOutlet weak var floorBaseButton: UIButton!
    @IBOutlet weak var floorOneButton: UIButton!
    @IBOutlet weak var floorTwoButton: UIButton!
    @IBOutlet weak var floorThreeButton: UIButton!
    
    @IBOutlet weak var zoneCard: UIView!
    @IBOutlet weak var floorCard: UIView!
    
    @IBAction func finishSelectingLocation(_ sender: UIBarButtonItem) {
        
        if prevFloorClicked != "" && prevZoneClicked != "" {
            performSegue(withIdentifier: "redpathToSummarySegue", sender: self)
        } else {
            print("Please select a floor & zone.")
        }
        
    }
    
    @IBAction func toggleFloor(_ sender: UIButton) {
        
        switch self.prevFloorClicked {
            
               case "B":
                   floorBaseButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                   floorBaseButton.setTitleColor(UIColor.black, for: .normal)
               case "1":
                   floorOneButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                   floorOneButton.setTitleColor(UIColor.black, for: .normal)
               case "2":
                   floorTwoButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                   floorTwoButton.setTitleColor(UIColor.black, for: .normal)
               case "3":
                   floorThreeButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                   floorThreeButton.setTitleColor(UIColor.black, for: .normal)

               
               default:
                   print("default")
                   
               }
               
               switch sender {
                
               case floorBaseButton:
                   sender.backgroundColor = UIColor.black
                   floorBaseButton.setTitleColor(UIColor.white, for: .normal)
                   self.prevFloorClicked = "B"
                
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
            
               default:
                   print("")
               }
               
               OrderSummaryViewController.floor = prevFloorClicked
               
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zoneCard.card()
        floorCard.card()
        
        view.setGradientBackground(colorA: Colors.lightBlue, colorB: Colors.lightPurple)
        
        floorBaseButton.setTitleColor(UIColor.black, for: .normal)
        floorOneButton.setTitleColor(UIColor.black, for: .normal)
        floorTwoButton.setTitleColor(UIColor.black, for: .normal)
        floorThreeButton.setTitleColor(UIColor.black, for: .normal)
      
        floorBaseButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorOneButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorTwoButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        floorThreeButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
       

    }

}
