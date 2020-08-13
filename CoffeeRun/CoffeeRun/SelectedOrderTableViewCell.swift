//
//  SelectedOrderTableViewCell.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/11/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class SelectedOrderTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 0.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setOrder(order: Order) {
        vendorLabel.text = order.restaurant.replacingOccurrences(of: "_", with: " ")
        itemLabel.text = order.size + " " + order.beverage
        detailsLabel.text = order.details
        costLabel.text = "Cost: $" + order.cost
        profitLabel.text = "Est. Profit: $" + String(round(Double(order.cost)! * 0.15 * 100) / 100)
        createdAtLabel.text = "Placed " + order.time
        creatorLabel.text = "by " + order.creator
        locationLabel.text = order.library + " " + order.floor + order.zone
    }
    
}
