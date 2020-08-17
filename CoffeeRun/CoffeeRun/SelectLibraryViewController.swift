//
//  SelectLibraryViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/16/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class SelectLibraryViewController: UIViewController {

    //MARK: Actions
    @IBAction func mclennanButton(_ sender: UIButton) {
        
        OrderSummaryViewController.library = "McLennan Library"
        
        performSegue(withIdentifier: "toMcLennanSegue", sender: self)
    }
    
    @IBAction func redpathButton(_ sender: Any) {
        
        OrderSummaryViewController.library = "Redpath"
    }
    
    @IBAction func lawButton(_ sender: Any) {
        
        OrderSummaryViewController.library = "Law Library"
    }
    
    @IBAction func musicButton(_ sender: Any) {
        
        OrderSummaryViewController.library = "Music Library"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}
