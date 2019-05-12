//
//  UIImage.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 01/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
