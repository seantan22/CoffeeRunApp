//
//  SelectLibraryViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/16/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class SelectLibraryViewController: UIViewController {
    
    @IBOutlet weak var mclennanButton: UIButton!
    @IBOutlet weak var redpathButton: UIButton!
    @IBOutlet weak var lawButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    
    //MARK: Actions
    @IBAction func mclennanButton(_ sender: UIButton) {
        
        OrderSummaryViewController.library = "McLennan Library"
        
        performSegue(withIdentifier: "toMcLennanSegue", sender: self)
    }
    
    @IBAction func redpathButton(_ sender: UIButton) {
        
        OrderSummaryViewController.library = "Redpath"
        
         performSegue(withIdentifier: "toRedpathSegue", sender: self)
    }
    
    @IBAction func lawButton(_ sender: UIButton) {
        
        OrderSummaryViewController.library = "Law Library"
        
        performSegue(withIdentifier: "toLawSegue", sender: self)
    }
    
    @IBAction func musicButton(_ sender: UIButton) {
        
        OrderSummaryViewController.library = "Music Library"
        
        performSegue(withIdentifier: "toMusicSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mclennanButton.libraryImage()
        redpathButton.libraryImage()
        lawButton.libraryImage()
        musicButton.libraryImage()
        
    }
    
}
