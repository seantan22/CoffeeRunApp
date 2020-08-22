//
//  PickupHistoryViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/13/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class PickupHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    static var pickupHistory: [ClosedOrder] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    // Number of Cells in Table
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PickupHistoryViewController.pickupHistory.count
     }
     
    // Cell Content
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let order = PickupHistoryViewController.pickupHistory[indexPath.row]
         let cell = tableView.dequeueReusableCell(withIdentifier: "PickupHistoryItem", for: indexPath) as! PickupHistoryTableViewCell
             cell.setOrder(order: order)
        
            return cell
    }
    
    func tableView(_ tableView: UITableView,
      editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCell.EditingStyle {
      return .none
    }
    
    
    
}
