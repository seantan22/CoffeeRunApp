//
//  WithdrawFundsViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/10/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class WithdrawFundsViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceTextField: UITextField!
    @IBOutlet weak var swipeArrowView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var balanceSection: UIView!
    
    
    var originPointArrow: CGPoint!
    
    
    let balance: Double = Double(ProfileViewController.balance)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.text = ""

        balanceTextField.becomeFirstResponder()
        
        balanceSection.card()
        
         view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
        
        self.balanceLabel.text = String(format: "$%.02f", balance)
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        balanceTextField.inputAccessoryView = toolBar
    
    }
    
    @IBAction func handleSwipe(_ sender: UIPanGestureRecognizer) {
        
        errorLabel.text = ""
        
        let translation = sender.translation(in: view)
        let position = sender.location(in: view)
        let velocity = sender.velocity(in: view)

        if velocity.x > 0 {
           if sender.state == .began {
                                 
                 originPointArrow = swipeArrowView.center
                 
            } else if sender.state == .changed {
                 
                  if position.x > 40.0 && position.x < 350.0 {
                          swipeArrowView.center = CGPoint(x: originPointArrow.x + translation.x, y: originPointArrow.y)
                  }
              
            } else if sender.state == .ended {
                if balanceTextField.text! == "" {
                    swipeArrowView.center = CGPoint(x: originPointArrow.x, y: originPointArrow.y)
                    self.errorLabel.text = "Please enter an amount."
                } else {
                    withdraw(user_id: UserDefaults.standard.string(forKey: "user_id")!,
                            funds: balanceTextField.text!) {(result: Response) in
                                
                        if result.result {
                            ProfileViewController.balance = result.response[0]
                           
                            DispatchQueue.main.async {
                                self.balanceLabel.text = String(format: "$%.02f", self.balance)
                                
                                let alert = UIAlertController(title: "Withdrawal Successful!", message: "", preferredStyle: .alert)

                                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
                                    self.performSegue(withIdentifier: "withdrawToProfileSegue", sender: self)
                                }))
                                self.present(alert, animated: true)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.swipeArrowView.center = CGPoint(x: self.originPointArrow.x, y: self.originPointArrow.y)
                                self.errorLabel.text = result.response[0]
                            }
                            
                        }
                    }
                }
            }
        }
    }
    

    @objc func doneClicked() {
        view.endEditing(true)
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
    
    
    // POST /withdraw
    func withdraw(user_id: String, funds: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: URLs.URL + "withdraw") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonLogin = [
            "user_id": user_id,
            "fund": funds
        ]
        
        let dataLogin: Data
        do {
            dataLogin = try JSONSerialization.data(withJSONObject: jsonLogin, options: [] )
        } catch {
            print("Error: Unable to convert JSON to Data object")
            return
        }
       
        let task = session.uploadTask(with: request, from: dataLogin) { data, response, error in
            if let data = data {
                var withdrawResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    withdrawResponse.result = jsonResponse.result
                    withdrawResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(withdrawResponse)
            }
        }
        task.resume()
    }

}
