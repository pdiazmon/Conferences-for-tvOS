//
//  AppCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

final class AppCoordinator {
    let window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
    }
}
