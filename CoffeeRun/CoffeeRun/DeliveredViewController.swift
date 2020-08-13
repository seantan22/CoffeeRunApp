//
//  DeliveredViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/7/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class DeliveredViewController: UIViewController {
    
    var rating: Double = 5
    var tipPercentage: Double = 0.15
    static var subtotal: String = String()
    
    //MARK: Properties
    @IBOutlet weak var firstStar: UIButton!
    @IBOutlet weak var secondStar: UIButton!
    @IBOutlet weak var thirdStar: UIButton!
    @IBOutlet weak var fourthStar: UIButton!
    @IBOutlet weak var fifthStar: UIButton!
    @IBOutlet weak var tipFifteenBtn: UIButton!
    @IBOutlet weak var tipTwentyBtn: UIButton!
    @IBOutlet weak var tipTwentyFiveBtn: UIButton!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    //MARK: Actions
    @IBAction func toggleRating(_ sender: UIButton) {
        
        switch sender {
        
        case firstStar:
            rating = 1
            firstStar.isSelected = true
            secondStar.isSelected = false
            thirdStar.isSelected = false
            fourthStar.isSelected = false
            fifthStar.isSelected = false
        
        case secondStar:
            rating = 2
            firstStar.isSelected = true
            secondStar.isSelected = true
            thirdStar.isSelected = false
            fourthStar.isSelected = false
            fifthStar.isSelected = false
        
        case thirdStar:
            rating = 3
            firstStar.isSelected = true
            secondStar.isSelected = true
            thirdStar.isSelected = true
            fourthStar.isSelected = false
            fifthStar.isSelected = false
            
        case fourthStar:
            rating = 4
            firstStar.isSelected = true
            secondStar.isSelected = true
            thirdStar.isSelected = true
            fourthStar.isSelected = true
            fifthStar.isSelected = false
        
        case fifthStar:
            rating = 5
            firstStar.isSelected = true
            secondStar.isSelected = true
            thirdStar.isSelected = true
            fourthStar.isSelected = true
            fifthStar.isSelected = true
        
        default:
            return
            
        }
        
    }
    
    
    @IBAction func toggleTip(_ sender: UIButton) {
        
        var tipAmount: Double = Double()
        
        if sender == tipFifteenBtn {
            tipFifteenBtn.isSelected = true
            tipFifteenBtn.isUserInteractionEnabled = false
            tipTwentyBtn.isSelected = false
            tipTwentyBtn.isUserInteractionEnabled = true
            tipTwentyFiveBtn.isSelected = false
            tipTwentyFiveBtn.isUserInteractionEnabled = true
            tipPercentage = 0.15
            tipAmount = round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100
            tipAmountLabel.text = String(format: "$%.02f", tipAmount)
            totalAmountLabel.text = String(format: "$%.02f", tipAmount + Double(DeliveredViewController.subtotal)!)
        } else if sender == tipTwentyBtn  {
            tipFifteenBtn.isSelected = false
            tipFifteenBtn.isUserInteractionEnabled = true
            tipTwentyBtn.isSelected = true
            tipTwentyBtn.isUserInteractionEnabled = false
            tipTwentyFiveBtn.isSelected = false
            tipTwentyFiveBtn.isUserInteractionEnabled = true
            tipPercentage = 0.20
            tipAmount = round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100
            tipAmountLabel.text = String(format: "$%.02f", tipAmount)
            totalAmountLabel.text = String(format: "$%.02f", tipAmount + Double(DeliveredViewController.subtotal)!)
        } else if sender == tipTwentyFiveBtn {
            tipFifteenBtn.isSelected = false
            tipFifteenBtn.isUserInteractionEnabled = true
            tipTwentyBtn.isSelected = false
            tipTwentyBtn.isUserInteractionEnabled = true
            tipTwentyFiveBtn.isSelected = true
            tipTwentyFiveBtn.isUserInteractionEnabled = false
            tipPercentage = 0.25
            tipAmount = round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100
            tipAmountLabel.text = String(format: "$%.02f", tipAmount)
            totalAmountLabel.text = String(format: "$%.02f", tipAmount + Double(DeliveredViewController.subtotal)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        
        firstStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        secondStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        thirdStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        fourthStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        fifthStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        
        tipFifteenBtn.setBackgroundColor(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), for: .normal)
        tipFifteenBtn.setBackgroundColor(UIColor.black, for: .selected)
        tipTwentyBtn.setBackgroundColor(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), for: .normal)
        tipTwentyBtn.setBackgroundColor(UIColor.black, for: .selected)
        tipTwentyFiveBtn.setBackgroundColor(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), for: .normal)
        tipTwentyFiveBtn.setBackgroundColor(UIColor.black, for: .selected)
        
        tipFifteenBtn.isSelected = true
        
        subtotalLabel.text = "$" + DeliveredViewController.subtotal
        tipAmountLabel.text = String(format: "$%.02f", round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100)
        totalAmountLabel.text = String(format: "$%.02f", round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100 + Double(DeliveredViewController.subtotal)!)
    }
    

}

extension UIButton {

  func setBackgroundColor(_ color: UIColor, for forState: UIControl.State) {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
    UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    let colorImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.setBackgroundImage(colorImage, for: forState)
  }

}
