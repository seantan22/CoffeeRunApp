//
//  ConfirmSelectionViewController.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/11/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

class ConfirmSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var testURL = "http://localhost:5000/"
    var deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    static var selectedOrders: Array<Order> = Array()

    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    @IBOutlet weak var selectedOrdersLabel: UILabel!
    @IBOutlet weak var estProfitLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
               ])
        
        selectedOrdersLabel.text = "You've selected " + String(ConfirmSelectionViewController.selectedOrders.count) + " orders."
        
        var totalCost: Double = 0.0
        
        for order in ConfirmSelectionViewController.selectedOrders {
            totalCost += Double(order.cost)!
        }
        
        estProfitLabel.text = "Your estimated profit is $" + String(round(totalCost * 0.15 * 100) / 100) + "."

    }
    
    // Number of Cells in Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return ConfirmSelectionViewController.selectedOrders.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
    // Space between cells
    private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = UIColor.white
        return spacer
    }
    
   // Cell Content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let order = ConfirmSelectionViewController.selectedOrders[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedOrderItem", for: indexPath) as! SelectedOrderTableViewCell
            cell.setOrder(order: order)
            return cell
   }
    
    
    

}
