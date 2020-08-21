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
//        self.layer.borderWidth = 0.5
    }
    
    func mainButton() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 25
        self.applyShadow()
        self.setGradientBackground(colorA: Colors.darkPurple, colorB: Colors.darkBlue)
    }
    
}

extension UIPickerView {
    
    func applyDesign() {
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//        self.layer.borderWidth = 1.0
    }
    
}

extension UIView {
    
    func card() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.setGradientBackground(colorA: Colors.cardA, colorB: Colors.cardB)
    }
    
    func receipt() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.75
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.setGradientBackground(colorA: Colors.receiptA, colorB: Colors.receiptB)
    }

    func setGradientBackground(colorA: UIColor, colorB: UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorA.cgColor, colorB.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}


