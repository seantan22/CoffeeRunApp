//
//  TripDenyViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/8/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class TripDenyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        
        view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
    }
    


}
