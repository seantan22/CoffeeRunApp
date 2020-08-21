//
//  DeliveredViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/7/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class DeliveredViewController: UIViewController {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    var window: UIWindow?
    
    static var gstRate: String = String()
    static var qstRate: String = String()
    static var deliveryFeeRate: String = String()
    
    var rating: Double = 5
    var tipPercentage: Double = 0.10
    
    static var subtotal: String = String()
    
    static var costWithTaxesAndFees: String = String()
    
    static var delivererUsername: String = String()
    
    //MARK: Properties
    @IBOutlet weak var firstStar: UIButton!
    @IBOutlet weak var secondStar: UIButton!
    @IBOutlet weak var thirdStar: UIButton!
    @IBOutlet weak var fourthStar: UIButton!
    @IBOutlet weak var fifthStar: UIButton!
    @IBOutlet weak var tipABtn: UIButton!
    @IBOutlet weak var tipBBtn: UIButton!
    @IBOutlet weak var tipCBtn: UIButton!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBAction func clickCompleteOrder(_ sender: UIBarButtonItem) {
        
        sender.isEnabled = false
        completeOrder(  user_id: UserDefaults.standard.string(forKey: "user_id")!,
                        order_id: UserDefaults.standard.string(forKey: "order_id")!,
                        delivery_username: DeliveredViewController.delivererUsername,
                        rating: String(rating),
                        cost: DeliveredViewController.subtotal,
                        tip: String(tipPercentage)) {(result: Response) in
            
                if result.result {
                    OrderExistenceViewController.doesOrderExist = false
                    UserDefaults.standard.removeObject(forKey: "order_id")
                    
                    self.getNewBalanceAfterOrder(user_id: UserDefaults.standard.string(forKey: "user_id")!) {(result: Response) in
                        if result.result {
                            ProfileViewController.balance = result.response[0]
                        }
                    }
                    
                    self.run(after: 1000) {
                        self.performSegue(withIdentifier: "completeOrderToNewOrderSegue", sender: self)
                    }
                    
                }
        }
        
    }
    
    
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
        
        if sender == tipABtn {
            tipABtn.isSelected = true
            tipABtn.isUserInteractionEnabled = false
            tipBBtn.isSelected = false
            tipBBtn.isUserInteractionEnabled = true
            tipCBtn.isSelected = false
            tipCBtn.isUserInteractionEnabled = true
            tipPercentage = 0.10
            tipAmount = round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100
            tipAmountLabel.text = String(format: "$%.02f", tipAmount)
            totalAmountLabel.text = String(format: "$%.02f", tipAmount + Double(DeliveredViewController.costWithTaxesAndFees)!)
        } else if sender == tipBBtn  {
            tipABtn.isSelected = false
            tipABtn.isUserInteractionEnabled = true
            tipBBtn.isSelected = true
            tipBBtn.isUserInteractionEnabled = false
            tipCBtn.isSelected = false
            tipCBtn.isUserInteractionEnabled = true
            tipPercentage = 0.15
            tipAmount = round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100
            tipAmountLabel.text = String(format: "$%.02f", tipAmount)
            totalAmountLabel.text = String(format: "$%.02f", tipAmount + Double(DeliveredViewController.costWithTaxesAndFees)!)
        } else if sender == tipCBtn {
            tipABtn.isSelected = false
            tipABtn.isUserInteractionEnabled = true
            tipBBtn.isSelected = false
            tipBBtn.isUserInteractionEnabled = true
            tipCBtn.isSelected = true
            tipCBtn.isUserInteractionEnabled = false
            tipPercentage = 0.20
            tipAmount = round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100
            tipAmountLabel.text = String(format: "$%.02f", tipAmount)
            totalAmountLabel.text = String(format: "$%.02f", tipAmount + Double(DeliveredViewController.costWithTaxesAndFees)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        
        let gstRate = Double(DeliveredViewController.gstRate)!
        let qstRate = Double(DeliveredViewController.qstRate)!
        let deliveryFeeRate = Double(DeliveredViewController.deliveryFeeRate)!
        
        let subtotal = Double(DeliveredViewController.subtotal)!
        let gstAmount = round(subtotal * gstRate * 100) / 100
        let qstAmount = round(subtotal * qstRate * 100) / 100
        let deliveryFee = (round(subtotal * deliveryFeeRate * 100) / 100) + 1.0
        let totalAmount = subtotal + gstAmount + qstAmount + deliveryFee
        DeliveredViewController.costWithTaxesAndFees = String(totalAmount)
        
        subtotalLabel.text = String(format: "$%.02f", round(Double(DeliveredViewController.costWithTaxesAndFees)! * 100) / 100)
        tipAmountLabel.text = String(format: "$%.02f", round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100)
        totalAmountLabel.text = String(format: "$%.02f", round(tipPercentage * Double(DeliveredViewController.subtotal)! * 100) / 100 + Double(DeliveredViewController.costWithTaxesAndFees)!)
        
        firstStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        secondStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        thirdStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        fourthStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        fifthStar.setImage(UIImage.init(systemName: "star.fill"), for: .selected)
        
        tipABtn.setBackgroundColor(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), for: .normal)
        tipABtn.setBackgroundColor(UIColor.black, for: .selected)
        tipBBtn.setBackgroundColor(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), for: .normal)
        tipBBtn.setBackgroundColor(UIColor.black, for: .selected)
        tipCBtn.setBackgroundColor(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), for: .normal)
        tipCBtn.setBackgroundColor(UIColor.black, for: .selected)
        
        firstStar.isSelected = true
        secondStar.isSelected = true
        thirdStar.isSelected = true
        fourthStar.isSelected = true
        fifthStar.isSelected = true
        tipABtn.isSelected = true

    }
    
    //MARK: Response
      struct Response: Decodable {
          var result: Bool
          var response: Array<String>
          init() {
              self.result = false
              self.response = Array()
          }
      }
    
    // POST /completeOrder
    func completeOrder(user_id: String,
                     order_id: String,
                     delivery_username: String,
                     rating: String,
                     cost: String,
                     tip: String,
                     completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "completeOrder") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonComplete = [
            "user_id": user_id,
            "order_id": order_id,
            "delivery_username": delivery_username,
            "rating": rating,
            "cost": cost,
            "tip": tip
        ]
        
        let dataComplete: Data
        do {
            dataComplete = try JSONSerialization.data(withJSONObject: jsonComplete, options: [] )
        } catch {
            print("Error: Unable to convert JSON to Data object")
            return
        }
       
        let task = session.uploadTask(with: request, from: dataComplete) { data, response, error in
            if let data = data {
                var completeOrderResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    completeOrderResponse.result = jsonResponse.result
                    completeOrderResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(completeOrderResponse)
            }
        }
        task.resume()
    }
    
    // POST /getNewBalanceAfterOrder
    func getNewBalanceAfterOrder(user_id: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "getNewBalanceAfterOrder") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(user_id, forHTTPHeaderField: "user_id")
       
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                var newBalanceResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    newBalanceResponse.result = jsonResponse.result
                    newBalanceResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(newBalanceResponse)
            }
        }
        task.resume()
    }
    
    func run(after milliseconds: Int, completion: @escaping() -> Void) {
        let deadline = DispatchTime.now() + .milliseconds(milliseconds)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion()
        }
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
