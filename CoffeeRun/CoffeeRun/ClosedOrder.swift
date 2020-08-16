//
//  Order.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/9/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import Foundation

class ClosedOrder: Decodable {
    
    var id: String
    var time_opened: String
    var time_closed: String
    var payer: String
    var payee: String
    var finalPrice: String
    var rating: String
    var size: String
    var beverage: String
    var vendor: String
    
    init(id: String,
         time_opened: String,
         time_closed: String,
         payer: String,
         payee: String,
         finalPrice: String,
         rating: String,
         size: String,
         beverage: String,
         vendor: String) {
            self.id = id
            self.time_opened = time_opened
            self.time_closed = time_closed
            self.payer = payer
            self.payee = payee
            self.finalPrice = finalPrice
            self.rating = rating
            self.size = size
            self.beverage = beverage
            self.vendor = vendor
    }

}

