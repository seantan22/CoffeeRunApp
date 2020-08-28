//
//  Constants.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/20/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    
    // GRADIENT #1
    static let lightBlue = UIColor(red: 135/255, green: 169/255, blue: 255/255, alpha: 1.0)
    static let lightPurple = UIColor(red: 215/255, green: 175/255, blue: 255/255, alpha: 1.0)
    
    // GRADIENT #2
    static let darkBlue = UIColor(red: 86/255, green: 86/255, blue: 255/255, alpha: 1.0)
    static let darkPurple = UIColor(red: 141/255, green: 26/255, blue: 249/255, alpha: 1.0)
    
    // GRADIENT #3
    static let cardA = UIColor(red: 240/255, green: 250/255, blue: 255/255, alpha: 1.0)
    static let cardB = UIColor(red: 245/255, green: 250/255, blue: 255/255, alpha: 1.0)
    
    //GRADIENT #4
    static let textInputA = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.7)
    static let textInputB = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 0.7)
    
    // GRADIENT #5 - Awaiting Runner Badge
    static let awaitingA = UIColor(red: 255/255, green: 231/255, blue: 108/255, alpha: 0.7)
    static let awaitingB = UIColor(red: 255/255, green: 247/255, blue: 141/255, alpha: 0.7)
    
    // GRADIENT #6 - In Progress Badge
    static let progressA = UIColor(red: 255/255, green: 231/255, blue: 108/255, alpha: 0.7)
    static let progressB = UIColor(red: 255/255, green: 247/255, blue: 141/255, alpha: 0.7)
    
    
    // STATUS LABELS
    static let statusBlue = UIColor(red: 86/255, green: 86/255, blue: 255/255, alpha: 1.0)
    static let statusGreen = UIColor(red: 54/255, green: 211/255, blue: 151/255, alpha: 1.0)
    
    // ORDERS
    static let selectBlue = UIColor(red: 196/255, green: 243/255, blue: 253/255, alpha: 0.8)
}

struct URLs {
   
    static let testingURL = "http://localhost:5000/"
    static let deployedURL = "https://coffeerunapp.herokuapp.com/"
    
    static let URL = deployedURL
    
}
