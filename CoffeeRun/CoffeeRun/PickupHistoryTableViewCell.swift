//
//  PickupHistoryTableViewCell.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/16/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class PickupHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var beverageLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var completedOnLabel: UILabel!
    @IBOutlet weak var deliveredToLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.card()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setOrder(order: ClosedOrder) {
        
        let cost = Double(order.finalPrice)!
        
        vendorLabel.text = order.vendor.replacingOccurrences(of: "_", with: " ")
        beverageLabel.text = order.size + " " + order.beverage
        costLabel.text = String(format: "$%.02f", cost)
        completedOnLabel.text = order.time_closed
        deliveredToLabel.text = order.payer
    }

}
