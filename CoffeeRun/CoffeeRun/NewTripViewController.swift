//
//  RunViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 7/31/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class NewTripViewController: UIViewController {
    
    static var numOpenOrders: String = String()

    //MARK: Properties
    @IBOutlet weak var availableOrdersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        availableOrdersLabel.text = NewTripViewController.numOpenOrders
    }

}
