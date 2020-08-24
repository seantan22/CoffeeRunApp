//
//  ConfirmSignUpViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/3/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ConfirmSignUpViewController: UIViewController, UITextFieldDelegate {
    
    var result: Bool = false
    
    static var user_id: String = String()
    static var username: String = String()
    
    //MARK: Properties
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var d1TextField: UITextField!
    @IBOutlet weak var d2TextField: UITextField!
    @IBOutlet weak var d3TextField: UITextField!
    @IBOutlet weak var d4TextField: UITextField!
    @IBOutlet weak var d5TextField: UITextField!
    @IBOutlet weak var d6TextField: UITextField!
    
    //MARK: Actions
    @IBAction func verifyUser(_ sender: UIBarButtonItem) {
        
        errorLabel.text = ""
        
        let codeArray = [d1TextField.text!, d2TextField.text!, d3TextField.text!, d4TextField.text!, d5TextField.text!, d6TextField.text!]

        let code = codeArray.joined()
        
        verify(user_id: ConfirmSignUpViewController.user_id, code: code)
        
        run(after: 1000) {
            if self.result {
                
                UserDefaults.standard.set(ConfirmSignUpViewController.user_id, forKey: "user_id")
                UserDefaults.standard.set(ConfirmSignUpViewController.username, forKey: "username")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                    .changeRootViewController(tabBarController)
            } else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Incorrect Verification Code. Try Again."
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true);
        
        errorLabel.text = ""
        
        d1TextField.delegate = self
        d2TextField.delegate = self
        d3TextField.delegate = self
        d4TextField.delegate = self
        d5TextField.delegate = self
        d6TextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        d1TextField.becomeFirstResponder()
        
         view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string != "" {
            if textField.text == "" {
                textField.text = string
            } else {
                if textField == d1TextField {
                    d2TextField.becomeFirstResponder()
                    d2TextField.text = string
                } else if textField == d2TextField {
                    d3TextField.becomeFirstResponder()
                    d3TextField.text = string
                } else if textField == d3TextField {
                    d4TextField.becomeFirstResponder()
                    d4TextField.text = string
                } else if textField == d4TextField {
                    d5TextField.becomeFirstResponder()
                    d5TextField.text = string
                } else if textField == d5TextField {
                    d6TextField.becomeFirstResponder()
                    d6TextField.text = string
                } else if textField == d6TextField {
                    textField.resignFirstResponder()
                }
            }
            return false
        } else {
            textField.text = string
            if textField.text!.count == 0 {
                if textField == d2TextField {
                    d1TextField.becomeFirstResponder()
                } else if textField == d3TextField {
                    d2TextField.becomeFirstResponder()
                } else if textField == d4TextField {
                   d3TextField.becomeFirstResponder()
                } else if textField == d5TextField {
                    d4TextField.becomeFirstResponder()
                } else if textField == d6TextField {
                   d5TextField.becomeFirstResponder()
                }
                return false
            }
            return false
        }
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
    var response = Response()
    
    // POST /verify
    func verify(user_id: String, code: String) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: URLs.URL + "verify") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonLogin = [
            "user_id": user_id,
            "verification_number": code
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
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    self.response.result = jsonResponse.result
                    self.response.response = jsonResponse.response
                    self.result = self.response.result
                } catch {
                    print("Error: Struct and JSON response do not match.")
                }
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
