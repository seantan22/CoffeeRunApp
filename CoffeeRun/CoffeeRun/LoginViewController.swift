//
//  LoginViewController.swift (Root View Controller)
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField  == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: Actions
    @IBAction func loginUser(_ sender: UIButton) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
       
        login(email: email, password: password)
        
        if UserDefaults.standard.value(forKey: "user_id") != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                .changeRootViewController(tabBarController)
        } else {
            return
        }
        
   }
    
    //MARK: Response
    struct Response: Decodable {
        var result: Bool
        var user_id: String
        init() {
            self.result = false
            self.user_id = String()
        }
    }
    var response = Response()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self;
        passwordTextField.delegate = self;
    }
    
    // POST /login
    func login(email: String, password: String) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: "http:/localhost:5000/login") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonLogin = [
            "email": email,
            "password": password
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
                self.parse(json: data)
                if self.response.result == true {
                    UserDefaults.standard.set(self.response.user_id, forKey: "user_id")
                }
            }
        }
        print("TEST")
        task.resume()
    }

    func parse(json: Data) {
        do {
            let jsonResponse = try JSONDecoder().decode(Response.self, from: json)
            response.result = jsonResponse.result
            response.user_id = jsonResponse.user_id
        } catch {
            print("Error: Struct and JSON response do not match.")
        }
    }
    
}
