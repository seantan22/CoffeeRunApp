//
//  ConfirmSignUpViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/3/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ConfirmSignUpViewController: UIViewController, UITextFieldDelegate {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    var result: Bool = false
    
    //MARK: Properties
    @IBOutlet weak var d1TextField: UITextField!
    @IBOutlet weak var d2TextField: UITextField!
    @IBOutlet weak var d3TextField: UITextField!
    @IBOutlet weak var d4TextField: UITextField!
    @IBOutlet weak var d5TextField: UITextField!
    @IBOutlet weak var d6TextField: UITextField!
    
    //MARK: Actions
    @IBAction func verifyUser(_ sender: UIBarButtonItem) {
        
        let codeArray = [d1TextField.text!, d2TextField.text!, d3TextField.text!, d4TextField.text!, d5TextField.text!, d6TextField.text!]

        let code = codeArray.joined()
        
        verify(user_id: UserDefaults.standard.string(forKey: "user_id")!, code: code)
        
        run(after: 1000) {
            if self.result {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                    .changeRootViewController(tabBarController)
            } else {
                print("Error: Invalid verification code.")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true);
        
        d1TextField.addTarget(self, action: #selector(self.textdidChange(textField:)), for: UIControl.Event.editingChanged)
        d2TextField.addTarget(self, action: #selector(self.textdidChange(textField:)), for: UIControl.Event.editingChanged)
        d3TextField.addTarget(self, action: #selector(self.textdidChange(textField:)), for: UIControl.Event.editingChanged)
        d4TextField.addTarget(self, action: #selector(self.textdidChange(textField:)), for: UIControl.Event.editingChanged)
        d5TextField.addTarget(self, action: #selector(self.textdidChange(textField:)), for: UIControl.Event.editingChanged)
        d6TextField.addTarget(self, action: #selector(self.textdidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        d1TextField.becomeFirstResponder()
    }
    
    @objc func textdidChange(textField: UITextField) {
        let text = textField.text
        
        if text?.utf16.count == 1 {
            
            switch textField {
                
            case d1TextField:
                d2TextField.becomeFirstResponder()
                break
            case d2TextField:
                d3TextField.becomeFirstResponder()
                break
            case d3TextField:
                d4TextField.becomeFirstResponder()
                break
            case d4TextField:
                d5TextField.becomeFirstResponder()
                break
            case d5TextField:
                d6TextField.becomeFirstResponder()
                break
            case d6TextField:
                d6TextField.resignFirstResponder()
                break
            default:
                break
            }
            
        } else {
            
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
        
        guard let url = URL(string: deployedURL + "verify") else {
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
