//
//  OrderPlacedViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/6/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class OrderPlacedViewController: UIViewController {
    
    //MARK: Actions
    @IBAction func donePlacingOrder(_ sender: UIBarButtonItem) {
        ExistingOrderViewController.orderStatus = "Awaiting Runner"
        self.performSegue(withIdentifier: "toOrderStatusSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        OrderExistenceViewController.doesOrderExist = true
    }

}
