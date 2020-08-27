//
//  OrderHistoryTableViewCell.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/16/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class OrderHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var beverageLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var completedAtLabel: UILabel!
    @IBOutlet weak var completedByLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.25
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setOrder(order: ClosedOrder) {
        
        let cost = Double(order.finalPrice)!
        
        vendorLabel.text = order.vendor.replacingOccurrences(of: "_", with: " ")
        beverageLabel.text = order.size + " " + order.beverage
        costLabel.text = String(format: "$%.02f", cost)
        completedAtLabel.text = order.time_closed
        completedByLabel.text = order.payee
    
    }

}
