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
    private var mainCoordinator: MainCoordinator

    init(window: UIWindow?) {
        self.window = window
        self.mainCoordinator = MainCoordinator()
    }

    func start() {
        self.mainCoordinator.start()
        window?.rootViewController = mainCoordinator.tabBarController
        window?.makeKeyAndVisible()
    }
}
