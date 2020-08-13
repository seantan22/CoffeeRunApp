//
//  ResetPasswordViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/13/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //MARK: Actions
    @IBAction func resetPasswordButton(_ sender: UIButton) {
        
        
        // If successful, go to tab bar home
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .changeRootViewController(tabBarController)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()


        self.navigationItem.setHidesBackButton(true, animated: true);
        
    }
    

}
