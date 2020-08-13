//
//  ForgotPasswordViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/9/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"

    //MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    
    //MARK: Actions
    @IBAction func sendResetPasswordEmail(_ sender: UIButton) {
        
        let email = emailTextField.text!
        
        forgotPassword(email: email)
        
        
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
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
    
    // POST /forgotPassword
    func forgotPassword(email: String) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "forgetPassword") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonLogin = [
            "email": email,
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
                var forgotPasswordResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    forgotPasswordResponse.result = jsonResponse.result
                    forgotPasswordResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    

}
