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
    
    @IBOutlet weak var buttonAfloorB: UIButton!
    @IBOutlet weak var buttonBfloorB: UIButton!
    @IBOutlet weak var buttonCfloorB: UIButton!
    @IBOutlet weak var buttonDfloorB: UIButton!
    @IBOutlet weak var buttonEfloorB: UIButton!
    @IBOutlet weak var buttonFfloorB: UIButton!
    @IBOutlet weak var buttonGfloorB: UIButton!
    @IBOutlet weak var buttonHfloorB: UIButton!
    
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
 
    
    @IBOutlet weak var zoneCardB: UIView!
    @IBOutlet weak var zoneCard1: UIView!
    @IBOutlet weak var zoneCard2: UIView!
    @IBOutlet weak var zoneCard3: UIView!
    
    @IBOutlet weak var floorCard: UIView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func finishSelectingLocation(_ sender: UIBarButtonItem) {
        
        errorLabel.text = ""
        
        if prevFloorClicked == "" {
            errorLabel.text = "Please select a floor."
        } else if prevZoneClicked == "" {
            errorLabel.text = "Please select a zone."
        } else {
            performSegue(withIdentifier: "redpathToSummarySegue", sender: self)
        }
        
    }
    
    @IBAction func toggleZoneForCybertech(_ sender: UIButton) {
        
        clearZoneBasement()
        
        switch sender {
            
        case buttonAfloorB:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "A"
            
        case buttonBfloorB:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "B"
            
        case buttonCfloorB:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "C"
            
        case buttonDfloorB:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "D"
            
        case buttonEfloorB:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "E"
            
        case buttonFfloorB:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "F"
            
        case buttonGfloorB:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "G"
            
        case buttonHfloorB:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "H"
            
        default:
            print("")
        }
        
        OrderSummaryViewController.zone = prevZoneClicked
        
    }
    
    
    @IBAction func toggleZoneForFloorOne(_ sender: UIButton) {
        clearZoneFOne()
        
        
        switch sender {
            
        case buttonAfloor1:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "A"
            
        case buttonBfloor1:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "B"
            
        case buttonCfloor1:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "C"
            
        case buttonDfloor1:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "D"
            
        case buttonEfloor1:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "E"
            
        default:
            print("")
        }
        
        OrderSummaryViewController.zone = prevZoneClicked
    
    }
    
    
    @IBAction func toggleZoneForFloorTwo(_ sender: UIButton) {
    
        clearZoneFTwo()
        
        switch sender {
            
        case buttonAfloor2:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "A"
            
        case buttonBfloor2:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "B"
            
        case buttonCfloor2:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "C"
            
        case buttonDfloor2:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "D"
            
        default:
            print("")
        }
        
        OrderSummaryViewController.zone = prevZoneClicked
            
    }
    
    
    @IBAction func toggleZoneForFloorThree(_ sender: UIButton) {
        
        switch sender {
            
        case buttonAfloor3:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "A"
            
        case buttonBfloor3:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "B"
            
        case buttonCfloor3:
            sender.backgroundColor = UIColor.systemGreen
            self.prevZoneClicked = "C"
            
        default:
            print("")
        }
        
        OrderSummaryViewController.zone = prevZoneClicked
        
    }
    
    @IBAction func toggleFloor(_ sender: UIButton) {
        
        switch self.prevFloorClicked {
            
               case "B":
                   floorBaseButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                   floorBaseButton.setTitleColor(UIColor.black, for: .normal)
                   clearZoneBasement()
            
               case "1":
                   floorOneButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                   floorOneButton.setTitleColor(UIColor.black, for: .normal)
                   clearZoneFOne()
                
               case "2":
                   floorTwoButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                   floorTwoButton.setTitleColor(UIColor.black, for: .normal)
                   clearZoneFTwo()
            
               case "3":
                   floorThreeButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                   floorThreeButton.setTitleColor(UIColor.black, for: .normal)
                   clearZoneFThree()
               
               default:
                   print("")
                   
               }
        
                self.prevZoneClicked = ""
               
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
    
    func clearZoneBasement(){
        switch self.prevZoneClicked {
                                
        case "A":
           buttonAfloorB.backgroundColor = UIColor.clear
        case "B":
           buttonBfloorB.backgroundColor = UIColor.clear
        case "C":
           buttonCfloorB.backgroundColor = UIColor.clear
        case "D":
           buttonDfloorB.backgroundColor = UIColor.clear
        case "E":
           buttonEfloorB.backgroundColor = UIColor.clear
        case "F":
           buttonFfloorB.backgroundColor = UIColor.clear
        case "G":
           buttonGfloorB.backgroundColor = UIColor.clear
        case "H":
           buttonHfloorB.backgroundColor = UIColor.clear
        default:
           print("")
           
        }
    }
    
    func clearZoneFOne(){
        switch self.prevZoneClicked {
        case "A":
           buttonAfloor1.backgroundColor = UIColor.clear
        case "B":
           buttonBfloor1.backgroundColor = UIColor.clear
        case "C":
           buttonCfloor1.backgroundColor = UIColor.clear
        case "D":
           buttonDfloor1.backgroundColor = UIColor.clear
        case "E":
           buttonEfloor1.backgroundColor = UIColor.clear
        default:
           print("")
           
        }
    }
    
    func clearZoneFTwo(){
        switch self.prevZoneClicked {
                     
        case "A":
            buttonAfloor2.backgroundColor = UIColor.clear
        case "B":
            buttonBfloor2.backgroundColor = UIColor.clear
        case "C":
            buttonCfloor2.backgroundColor = UIColor.clear
        case "D":
            buttonDfloor2.backgroundColor = UIColor.clear
        default:
            print("")
        }
    }
    
    func clearZoneFThree(){
        switch self.prevZoneClicked {
            
        case "A":
            buttonAfloor3.backgroundColor = UIColor.clear
        case "B":
            buttonBfloor3.backgroundColor = UIColor.clear
        case "C":
            buttonCfloor3.backgroundColor = UIColor.clear
        default:
            print("")
            
        }
    }
    
    func basementSegments(isHidden: Bool){
        
        zoneCardB.isHidden = isHidden
        zoneCard1.isHidden = !isHidden
        zoneCard2.isHidden = !isHidden
        zoneCard3.isHidden = !isHidden
        
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
       
        errorLabel.text = ""
    }

}
