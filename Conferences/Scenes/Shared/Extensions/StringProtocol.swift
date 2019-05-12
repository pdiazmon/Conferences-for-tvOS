//
//  StringProtocol.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 01/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

extension StringProtocol where Index == String.Index {
    func startIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
}
