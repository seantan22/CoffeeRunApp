//
//  SignUpViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/3/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField  == emailTextField {
            textField.resignFirstResponder()
            phoneTextField.becomeFirstResponder()
        } else if textField == phoneTextField {
            textField.resignFirstResponder()
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneTextField {
            let special = CharacterSet(charactersIn: "-")
            let fullCharset = special.union(CharacterSet.decimalDigits)
            let allowedCharacters = fullCharset
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        if textField == usernameTextField {
            let special = CharacterSet(charactersIn: "_.")
            let alphanum = CharacterSet.letters.union(CharacterSet.decimalDigits)
            let allowedCharacters = special.union(alphanum)
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    //MARK: Actions
    @IBAction func signupUser(_ sender: UIButton) {
        
        let email = emailTextField.text!
        let phone = phoneTextField.text!
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let confirmPassword = confirmPasswordTextField.text!
        
        if password == confirmPassword {
            signup(username: username, password: password, email: email, phone: phone) {(result: Response) in
                if result.result == true {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let confirmSignUpController = storyboard.instantiateViewController(withIdentifier: "ConfirmSignUpController")
                        self.navigationController?.pushViewController(confirmSignUpController, animated: true)
                        print("SIGN UP SUCCESSFUL")
                    }
                } else {
                    print("Error: Sign Up Unsuccessful")
                }
            }
            
        } else {
            print("Error: Passwords do not match.")
        }
    }
    
    //MARK: Response
    struct Response: Decodable {
       var result: Bool
       var errorMessage: String
       init() {
           self.result = false
           self.errorMessage = String()
       }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self;
        phoneTextField.delegate = self;
        usernameTextField.delegate = self;
        passwordTextField.delegate = self;
        confirmPasswordTextField.delegate = self;

    }
    
    // POST /createUser
    func signup(username: String, password: String, email: String, phone: String,
                completion: @escaping(Response) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: "https://coffeerunapp.herokuapp.com/createUser") else {
            print("Error: Cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonLogin = [
            "username": username,
            "password": password,
            "email": email,
            "phone_number": phone
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
                var response = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    response.result = jsonResponse.result
                    response.errorMessage = jsonResponse.errorMessage
                    print(response.errorMessage)
                } catch {
                    print("Error: Struct and JSON response do not match.")
                }
                completion(response)
            }
        }
        task.resume()
    }
    


}
