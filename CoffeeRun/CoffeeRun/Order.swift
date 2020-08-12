//
//  Order.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/9/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import Foundation

class Order {
    
    var restaurant: String
    var size: String
    var beverage: String
    var details: String
    var time: String
    var library: String
    var floor: String
    var zone: String
    var creator: String
    var cost: String
    
    init(restaurant: String,
    size: String,
    beverage: String,
    details: String,
    time: String,
    library: String,
    floor: String,
    zone: String,
    creator: String,
    cost: String) {
        self.restaurant = restaurant
        self.size = size
        self.beverage = beverage
        self.details = details
        self.time = time
        self.library = library
        self.floor = floor
        self.zone = zone
        self.creator = creator
        self.cost = cost
    }
    
}
