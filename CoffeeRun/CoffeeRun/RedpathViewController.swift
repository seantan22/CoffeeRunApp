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
    
    @IBOutlet weak var buttonAfloor1: UIButton!
    @IBOutlet weak var buttonBfloor1: UIButton!
    @IBOutlet weak var buttonCfloor1: UIButton!
    @IBOutlet weak var buttonDfloor1: UIButton!
    @IBOutlet weak var buttonEfloor1: UIButton!
    
    @IBOutlet weak var buttonAfloor2: UIButton!
    @IBOutlet weak var buttonBfloor2: UIButton!
    @IBOutlet weak var buttonCfloor2: UIButton!
    @IBOutlet weak var buttonDfloor2: UIButton!
    
    @IBOutlet weak var buttonAfloor3: UIButton!
    @IBOutlet weak var buttonBfloor3: UIButton!
    @IBOutlet weak var buttonCfloor3: UIButton!
    @IBOutlet weak var buttonDfloor3: UIButton!
    
    @IBOutlet weak var zoneCardB: UIView!
    @IBOutlet weak var zoneCard1: UIView!
    @IBOutlet weak var zoneCard2: UIView!
    @IBOutlet weak var zoneCard3: UIView!
    
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
                   basementSegments(isHidden: false)
                
               case floorOneButton:
                   sender.backgroundColor = UIColor.black
                   floorOneButton.setTitleColor(UIColor.white, for: .normal)
                   self.prevFloorClicked = "1"
                   floorOneSegments(isHidden: false)
                    
               case floorTwoButton:
                   sender.backgroundColor = UIColor.black
                   floorTwoButton.setTitleColor(UIColor.white, for: .normal)
                   self.prevFloorClicked = "2"
                   floorTwoSegments(isHidden: false)
                
               case floorThreeButton:
                   sender.backgroundColor = UIColor.black
                   floorThreeButton.setTitleColor(UIColor.white, for: .normal)
                   self.prevFloorClicked = "3"
                   floorThreeSegments(isHidden: false)
                
               default:
                   print("")
               }
               
               OrderSummaryViewController.floor = prevFloorClicked
               
    }
    
    func basementSegments(isHidden: Bool){
        
        zoneCardB.isHidden = isHidden
        zoneCard1.isHidden = !isHidden
        zoneCard2.isHidden = !isHidden
        zoneCard3.isHidden = !isHidden
        
        if(!isHidden){
            
        }
        
    }
    
    func floorOneSegments(isHidden: Bool){
       
        zoneCardB.isHidden = !isHidden
        zoneCard1.isHidden = isHidden
        zoneCard2.isHidden = !isHidden
        zoneCard3.isHidden = !isHidden

    }
    
    func floorTwoSegments(isHidden: Bool){
       
        zoneCardB.isHidden = !isHidden
        zoneCard1.isHidden = !isHidden
        zoneCard2.isHidden = isHidden
        zoneCard3.isHidden = !isHidden

    }
    
    func floorThreeSegments(isHidden: Bool){
       
        zoneCardB.isHidden = !isHidden
        zoneCard1.isHidden = !isHidden
        zoneCard2.isHidden = !isHidden
        zoneCard3.isHidden = isHidden

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zoneCardB.card()
        zoneCard1.card()
        zoneCard2.card()
        zoneCard3.card()
        floorCard.card()
        
        zoneCardB.isHidden = true
        zoneCard1.isHidden = true
        zoneCard2.isHidden = true
        zoneCard3.isHidden = true
        
        
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
