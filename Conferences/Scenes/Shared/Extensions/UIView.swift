//
//  UIView.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 01/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints

extension UIView {
    func updateConstraint(attribute: NSLayoutConstraint.Attribute, constant: CGFloat, multiplier: CGFloat = 1) {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = constant
//            constraint = constraint.constraintWithMultiplier(multiplier)
        }
        else {
            switch (attribute) {
            case .height:
                self.height(constant)
            case .width:
                self.width(constant)
            default:
                break
            }
        }
    }
    
    func updateConstraint(attribute: NSLayoutConstraint.Attribute, multiplier: CGFloat) {
//        self.constraints.forEach { print("[\(attribute.rawValue)] - \($0.firstAttribute.rawValue) - \($0.secondAttribute.rawValue)") }
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            let newConstraint = constraint.constraintWithMultiplier(multiplier)
            self.removeConstraint(constraint)
            self.addConstraint(newConstraint)
            self.layoutIfNeeded()
        }
        else {
        }
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
