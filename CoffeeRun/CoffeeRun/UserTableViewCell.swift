//
//  UserTableViewCell.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/11/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setUser(user: String) {
        usernameLabel.text = user
    }

}
