//
//  SeatLocationViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/5/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class SeatLocationViewController: UIViewController {
    
    //MARK: Actions
    @IBAction func toOrderSummary(_ sender: UIBarButtonItem) {
         
        // TODO: Set order summary static variable
        
        self.performSegue(withIdentifier: "toOrderSummarySegue", sender: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
