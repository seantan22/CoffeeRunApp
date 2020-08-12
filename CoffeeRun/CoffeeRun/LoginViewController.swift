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
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
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
        
        errorMsgLabel.text = ""

        let email = emailTextField.text!
        let password = passwordTextField.text!

        login(email: email, password: password) {(result: Response) in
            
            if result.result {
                if result.response[2] == "true" {
                    self.run(after: 1000) {
                        if UserDefaults.standard.value(forKey: "user_id") != nil {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                                .changeRootViewController(tabBarController)
                        } else {
                            return
                        }
                    }
                } else {
                    ConfirmSignUpViewController.user_id = result.response[0]
                    ConfirmSignUpViewController.username = result.response[1]
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "loginToVerifySegue", sender: self)
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    self.errorMsgLabel.text = result.response[0]
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true);
        
        emailTextField.delegate = self;
        passwordTextField.delegate = self;
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
    
    // POST /login
    func login(email: String, password: String, completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: testURL + "login") else {
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
                var loginResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    loginResponse.result = jsonResponse.result
                    loginResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                if loginResponse.result && loginResponse.response[2] == "true" {
                    UserDefaults.standard.set(loginResponse.response[0], forKey: "user_id")
                    UserDefaults.standard.set(loginResponse.response[1], forKey: "username")
                }
                completion(loginResponse)
            }
        }
        task.resume()
    }
    
    // Wait X milliseconds before running function
    func run(after milliseconds: Int, completion: @escaping() -> Void) {
        let deadline = DispatchTime.now() + .milliseconds(milliseconds)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion()
        }
    }
    
}
