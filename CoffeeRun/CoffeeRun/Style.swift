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
    
    func mainButton() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 25
        self.applyShadow()
        self.setGradientBackground(colorA: Colors.darkPurple, colorB: Colors.darkBlue)
    }
    
    func historyButton() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.applyShadow()
        self.setGradientBackground(colorA: Colors.darkPurple, colorB: Colors.darkBlue)
    }
    
    func cardButton() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    }
    
}

extension UIView {
    
    func card() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    }
    
    func receipt() {
        self.layer.masksToBounds = false
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

extension UITextField {
    
    func styleTextInput() {
        self.layer.cornerRadius = 25
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.setGradientBackground(colorA: Colors.textInputA, colorB: Colors.textInputB)
//        self.layer.borderColor = UIColor.black.cgColor
//        self.layer.borderWidth = 0.2
        self.layer.masksToBounds = true
        
    }
    
}

