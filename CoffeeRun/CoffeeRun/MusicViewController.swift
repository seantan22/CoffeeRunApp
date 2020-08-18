//
//  MusicViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/17/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class MusicViewController: UIViewController {

    @IBAction func finishSelectingLocation(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "musicToSummarySegue", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    

}
