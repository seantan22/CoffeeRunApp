//
//  ProfileViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
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
    
    //MARK: Response Structs
    struct UserProfileResponse: Decodable {
        var username: String
        var email: String
        var balance: Double
        init() {
            self.username = String()
            self.email = String()
            self.balance = 0.0
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

        self.getUserProfile(user_id: UserDefaults.standard.string(forKey: "user_id")!) {(result: UserProfileResponse) in
            DispatchQueue.main.async {
                self.usernameLabel.text = result.username
                self.balanceLabel.text = "$" + String(result.balance)
                self.emailLabel.text = result.email
            }
        }
    }
    
    
    // GET /getUser
    func getUserProfile(user_id: String, completion: @escaping(UserProfileResponse) -> ()) {
        
        let session = URLSession.shared

        guard let url = URL(string: "http:/localhost:5000/getUser") else {
         print("Error: Cannot create URL")
         return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(user_id, forHTTPHeaderField: "user_id")
        
        let task = session.dataTask(with: request) { data, response, error in
            
            var userProfileResponse: UserProfileResponse = UserProfileResponse()
            
            if let data = data {
                do {
                    let jsonResponse = try JSONDecoder().decode(UserProfileResponse.self, from: data)
                        userProfileResponse.username = jsonResponse.username
                        userProfileResponse.balance = jsonResponse.balance
                        userProfileResponse.email = jsonResponse.email
    
                } catch {
                    print("Error: Struct and JSON response do not match.")
                }
                completion(userProfileResponse)
            }
        }

        task.resume()
        
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
