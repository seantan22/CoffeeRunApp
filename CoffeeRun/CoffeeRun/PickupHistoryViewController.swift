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
        
        view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)
        tableView.backgroundColor = UIColor.clear
    }
    
    // Number of Cells in Table
     func numberOfSections(in tableView: UITableView) -> Int {
        return PickupHistoryViewController.pickupHistory.count
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
     }
     
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = UIColor.clear
        return spacer
    }
    
    // Cell Content
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let order = PickupHistoryViewController.pickupHistory[indexPath.section]
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
