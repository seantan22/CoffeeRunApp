//
//  HomeViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: Response
    struct Response: Decodable {
        var result: Bool
        var response: Array<String>
        init() {
            self.result = false
            self.response = Array()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProfile(user_id: UserDefaults.standard.string(forKey: "user_id")!) {(result: Response) in
            if result.result == true {
                    ProfileViewController.username = result.response[0]
                    ProfileViewController.email = result.response[1]
                    ProfileViewController.balance = result.response[2]
            } else {
                print(result.response[0])
            }
        }
    
    }
    
    // GET /getUser
    func loadProfile(user_id: String, completion: @escaping(Response) -> ()) {
        
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
            if let data = data {
                var profileResponse = Response()
                do {
                    let jsonResponse = try JSONDecoder().decode(Response.self, from: data)
                    profileResponse.result = jsonResponse.result
                    profileResponse.response = jsonResponse.response
                } catch {
                    print(error)
                }
                completion(profileResponse)
            }
        }
        task.resume()
    }
    
    
    
}
