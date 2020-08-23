//
//  ForgotPasswordViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/9/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

     //MARK: Properties
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    //MARK: Actions
    @IBAction func sendResetPasswordEmail(_ sender: UIButton) {
        
        errorLabel.text = ""
        
        let email = emailTextField.text!
        
        if email != "" {
            forgotPassword(email: email) {(result: Response) in
                
                if !result.result {
                    DispatchQueue.main.async {
                        self.errorLabel.text = result.response[0]
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Sent!", message: "A temporary password was sent to your email."
                            , preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
                            self.performSegue(withIdentifier: "resetToLoginSegue", sender: self)
                        }))
                        self.present(alert, animated: true)
                    }
                }
            }
        } else {
            errorLabel.text = "Enter your email address."
        }
    
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.text = ""
        
        sendButton.mainButton()
        emailTextField.styleTextInput()

       view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
       
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
    func forgotPassword(email: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: URLs.URL + "forgetPassword") else {
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
                completion(forgotPasswordResponse)
            }
        }
        task.resume()
    }
    

}
