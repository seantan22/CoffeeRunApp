//
//  ResetPasswordViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/13/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
     static var email: String = String()
    
    //MARK: Properties
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    
    
    //MARK: Actions
    @IBAction func resetPasswordButton(_ sender: UIButton) {
        
        errorLabel.text = ""
        
        if newPasswordTextField.text == "" || confirmPasswordTextField.text == "" {
            errorLabel.text = "Please enter in a new password."
        } else {
            if newPasswordTextField.text == confirmPasswordTextField.text {
                resetPassword(email: ResetPasswordViewController.email, password: newPasswordTextField.text!) {(result: Response) in
                   
                    DispatchQueue.main.async {
                        if result.result {
                                let alert = UIAlertController(title: "Your password has been reset.", message: "", preferredStyle: .alert)

                                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
                                    self.performSegue(withIdentifier: "unwindToLoginSegue", sender: self)
                                }))
                                self.present(alert, animated: true)
                        } else {
                            self.errorLabel.text = result.response[0]
                        }
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Passwords do not match."
                }
                
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true);
        
        view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
        
        newPasswordTextField.styleTextInput()
        confirmPasswordTextField.styleTextInput()
        resetButton.mainButton()
        
        errorLabel.text = ""
        
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
       
       // POST /updateForgottenPassword
    func resetPassword(email: String, password: String, completion: @escaping(Response) -> ()) {
           
           let session = URLSession.shared
           
        guard let url = URL(string: URLs.URL + "updateForgottenPassword") else {
               print("Error: Cannot create URL")
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           let jsonReset = [
               "email": email,
               "password": password,
           ]
           
           let dataReset: Data
           do {
               dataReset = try JSONSerialization.data(withJSONObject: jsonReset, options: [] )
           } catch {
               print("Error: Unable to convert JSON to Data object")
               return
           }
          
           let task = session.uploadTask(with: request, from: dataReset) { data, response, error in
               if let data = data {
                   var resetPasswordResponse = Response()
                   do {
                       let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                       resetPasswordResponse.result = jsonResponse.result
                       resetPasswordResponse.response = jsonResponse.response
                   } catch {
                       print(error)
                   }
                   completion(resetPasswordResponse)
               }
           }
           task.resume()
       }
    
    
    

}
