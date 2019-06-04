//
//  CoordinatorProtocol.swift
//  Conferences
//
//  Created by Zagahr on 26/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

enum CoordinatorEvent {
    case watchlistUpdated
    case continueWatchingUpdated
}

protocol Coordinator: AnyObject {
    var vc: UIViewController { get }
    
    func start()
}

