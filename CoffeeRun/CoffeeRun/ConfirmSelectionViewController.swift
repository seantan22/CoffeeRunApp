//
//  ConfirmSelectionViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/11/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ConfirmSelectionViewController: UIViewController {
    
    static var selectedOrders: Array<Order> = Array()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(ConfirmSelectionViewController.selectedOrders)

    }
    

}
