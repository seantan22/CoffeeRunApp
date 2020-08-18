//
//  Style.swift
//  CoffeeRun
//
//  Created by Sean Tan on 8/17/20.
//  Copyright © 2020 CoffeeRun. All rights reserved.
//

import UIKit

extension UIButton {
    
    func applyShadow() {
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
    }
    
    func libraryImage() {
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.75
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.layer.borderWidth = 0.5
    }
    
}

extension UIPickerView {
    
    func applyDesign() {
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.borderWidth = 1.0
    }
    
}
