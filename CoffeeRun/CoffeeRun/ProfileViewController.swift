//
//  ProfileViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    static var username: String = String()
    static var email: String = String()
    static var balance: String = String()
    
    //MARK: Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    //MARK: Actions
    @IBAction func logoutUser(_ sender: UIBarButtonItem) {
    
        logout(user_id: UserDefaults.standard.string(forKey: "user_id")!)

        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        // Transition to Login Screen
        if UserDefaults.standard.value(forKey: "user_id") == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                .changeRootViewController(loginNavigationController)
        } else {
            return
        }
    }
    
    struct LogoutResponse: Decodable {
        var result: Bool
        var msg: String
        init() {
            self.result = false
            self.msg = String()
        }
    }
    var logoutResponse = LogoutResponse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameLabel.text = ProfileViewController.username
        self.emailLabel.text = ProfileViewController.email
        self.balanceLabel.text = "$" + ProfileViewController.balance

    }
    
    // POST /logout
    func logout(user_id: String) {
        
        let session = URLSession.shared

        guard let url = URL(string: "http:/localhost:5000/logout") else {
         print("Error: Cannot create URL")
         return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonLogout = [
         "user_id": user_id
        ]

        let dataLogout: Data
        do {
         dataLogout = try JSONSerialization.data(withJSONObject: jsonLogout, options: [] )
        } catch {
         print("Error: Unable to convert JSON to Data object")
         return
        }

        let task = session.uploadTask(with: request, from: dataLogout) { data, response, error in
            if let data = data {
                 do {
                    let jsonResponse = try JSONDecoder().decode(LogoutResponse.self, from: data)
                    self.logoutResponse.msg = jsonResponse.msg
                    print(self.logoutResponse.msg)
                 } catch {
                     print("Error: Struct and JSON response do not match.")
                 }
                 if self.logoutResponse.result == true {
                    UserDefaults.standard.removeObject(forKey: "user_id")
                 }
            }
        }

        task.resume()
    }

}
