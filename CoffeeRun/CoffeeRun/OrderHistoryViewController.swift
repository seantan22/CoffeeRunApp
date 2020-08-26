//
//  OrderHistoryViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/13/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class OrderHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    static var orderHistory: [ClosedOrder] = Array()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

           tableView.delegate = self
           tableView.dataSource = self
        
            view.setGradientBackground(colorA: Colors.lightPurple, colorB: Colors.lightBlue)

    }
    
    // Number of Cells in Table
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OrderHistoryViewController.orderHistory.count
     }
     
    // Cell Content
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let order = OrderHistoryViewController.orderHistory[indexPath.row]
         let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryItem", for: indexPath) as! OrderHistoryTableViewCell
             cell.setOrder(order: order)
        
            return cell
    }
    
    func tableView(_ tableView: UITableView,
      editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCell.EditingStyle {
      return .none
    }

}
