//
//  PickupOrdersTableViewCell.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/9/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class PickupOrdersTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 10.0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }
    
    func setOrder(order: Order) {
        vendorLabel.text = order.restaurant.replacingOccurrences(of: "_", with: " ")
        itemLabel.text = order.size + " " + order.beverage
        costLabel.text = "$" + order.cost
        createdAtLabel.text = "Placed " + order.time
        usernameLabel.text = "by " + order.creator
        libraryLabel.text = order.library + " " + order.floor + order.zone
    }

}
