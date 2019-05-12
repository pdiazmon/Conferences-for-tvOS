//
//  Styleguide.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit


extension UIColor {

    static var primaryText: UIColor {
        return UIColor(white: 0.9, alpha: 1.0)
    }

    static var secondaryText: UIColor {
        return UIColor(white: 0.75, alpha: 1.0)
    }

    static var tertiaryText: UIColor {
        return UIColor(white: 0.55, alpha: 1.0)
    }

    static var panelBackground: UIColor {
        return UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
    }

    static var darkWindowBackground: UIColor {
        return UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.0)
    }

    static var elementBackground: UIColor {
        return UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
    }

    static var inactiveButton: UIColor {
        return UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
    }

    static var activeButton: UIColor {
        return UIColor(red:0.11, green:0.11, blue:0.11, alpha:1.0)
    }

    static var prefsPrimaryText: UIColor {
        return UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)
    }

    static var prefsSecondaryText: UIColor {
        return UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)
    }

    static var prefsTertiaryText: UIColor {
        return UIColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.00)
    }

    static var errorText: UIColor {
        return UIColor(red: 0.85, green: 0.18, blue: 0.18, alpha: 1.00)
    }

//    static var inactiveColor: UIColor {
//        return UIColor.init(hexString: "B3B3B3")
//    }

    static var activeColor: UIColor {
        return .white
    }

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
