//
//  ProfileViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    //MARK: Actions
    @IBAction func logoutUser(_ sender: UIButton) {
        
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
    
    //MARK: Response
    struct Response: Decodable {
        var result: Bool
        var msg: String
        init() {
            self.result = false
            self.msg = String()
        }
    }
    var response = Response()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                 self.parse(json: data)
                 if self.response.result == true {
                    UserDefaults.standard.removeObject(forKey: "user_id")
                 }
             }
         }
         
         task.resume()
    }
    
    func parse(json: Data) {
           do {
                let jsonResponse = try JSONDecoder().decode(Response.self, from: json)
                response.msg = jsonResponse.msg
                print(response.msg)
           } catch {
               print("Error: Struct and JSON response do not match.")
           }
       }
    
}
