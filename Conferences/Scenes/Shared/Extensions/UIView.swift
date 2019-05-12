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
    func updateConstraint(attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = constant
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
}
