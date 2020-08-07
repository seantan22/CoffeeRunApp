//
//  OrderExistenceViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/6/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class OrderExistenceViewController: UIViewController {
    
    static var doesOrderExist: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
          if OrderExistenceViewController.doesOrderExist {
                  self.performSegue(withIdentifier: "toExistingOrderSegue", sender: nil)
              } else {
                  self.performSegue(withIdentifier: "toNewOrderSegue", sender: nil)
              }
    }
}
