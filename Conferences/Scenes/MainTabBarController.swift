//
//  MainTabBarController.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 02/06/2019.
//  Copyright © 2019 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    enum Tab: Int {
        case conferences
        case watchlist
        case continuewatching
        
        var coordinator: Coordinator {
            switch self {
            case .conferences:
                return ConferencesCoordinator(mode: .allConferences)
            case .watchlist:
                return ConferencesCoordinator(mode: .watchList)
            case .continuewatching:
                return ConferencesCoordinator(mode: .continueWatching)
            }
        }
    }
    
    let conferences      = Tab.conferences.coordinator
    let watchlist        = Tab.watchlist.coordinator
    let continuewatching = Tab.continuewatching.coordinator

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [conferences.vc, watchlist.vc, continuewatching.vc]
        
        conferences.start()
    }
}

