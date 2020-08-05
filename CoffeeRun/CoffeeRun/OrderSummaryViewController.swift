//
//  OrderSummaryViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/5/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class OrderSummaryViewController: UIViewController {

    static var vendor: String = String()
    static var beverage: String = String()
    static var size: String = String()
    static var details: String = String()
    
    //MARK: Properties
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var beverageLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vendorLabel.text = OrderSummaryViewController.vendor
        sizeLabel.text = OrderSummaryViewController.size
        beverageLabel.text = OrderSummaryViewController.beverage
        detailsLabel.text = OrderSummaryViewController.details
        
    }

}
