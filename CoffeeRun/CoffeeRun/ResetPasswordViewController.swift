//
//  ResetPasswordViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/13/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"

    static var email: String = String()
    
    //MARK: Properties
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //MARK: Actions
    @IBAction func resetPasswordButton(_ sender: UIButton) {
        
        if newPasswordTextField.text == "" || confirmPasswordTextField.text == "" {
            print("Please enter in a new password.")
        } else {
            if newPasswordTextField.text == confirmPasswordTextField.text {
                resetPassword(email: ResetPasswordViewController.email, password: newPasswordTextField.text!) {(result: Response) in
                    
                    if result.result {
                        print("Success! Password reset.")
                    }
                    
                }
                performSegue(withIdentifier: "unwindToLoginSegue", sender: self)
            } else {
                print("Passwords do not match.")
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true);
        
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
           
           guard let url = URL(string: testURL + "updateForgottenPassword") else {
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
