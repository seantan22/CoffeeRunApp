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
        
        // Transition to Login Screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .changeRootViewController(loginNavigationController)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func logout(user_id: String) {
        
        UserDefaults.standard.removeObject(forKey: "user_id")
        
    }
    
}
