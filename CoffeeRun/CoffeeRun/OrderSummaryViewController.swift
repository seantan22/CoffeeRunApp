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
    static var library: String = String()
    static var floor: String = String()
    static var zone: String = String()
    static var cost: String = String()
    
    //MARK: Properties
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var beverageLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var zoneLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vendorLabel.text = OrderSummaryViewController.vendor.replacingOccurrences(of: "_", with: " ")
        sizeLabel.text = OrderSummaryViewController.size
        beverageLabel.text = OrderSummaryViewController.beverage
        detailsLabel.text = OrderSummaryViewController.details
        libraryLabel.text = OrderSummaryViewController.library
        floorLabel.text = OrderSummaryViewController.floor
        zoneLabel.text = OrderSummaryViewController.zone
        subtotalLabel.text = "$" + OrderSummaryViewController.cost
        
    }

}
