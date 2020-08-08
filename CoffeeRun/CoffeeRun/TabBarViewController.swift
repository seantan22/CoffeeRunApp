//
//  TabBarPickupViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/8/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var selectedViewController: UIViewController? {
        didSet {
            tabChangedTo(selectedIndex: selectedIndex)
        }
    }
    
    override var selectedIndex: Int {
        didSet {
            tabChangedTo(selectedIndex: selectedIndex)
        }
    }

    func tabChangedTo(selectedIndex: Int) {
        if(selectedIndex == 2){
            // Reset the stack
            // PickupNavigationControllerViewController?.setViewControllers(animated: false)
        }
    }
    


}
