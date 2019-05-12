//
//  MainCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit


final class MainCoordinator {
    let tabBarController: UITabBarController

//    private lazy var settingsScene: SettingsCoordinator = {
//        let coordinator = SettingsCoordinator()
//        coordinator.start()
//
//        return coordinator
//    }()


    init() {
        self.tabBarController = UITabBarController()
    }

    func start() {
        self.tabBarController.tabBar.tintColor = .primaryText
        self.tabBarController.tabBar.barTintColor = .elementBackground
//        self.tabBarController.setViewControllers([SplitViewController()], animated: false)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset        = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize            = CGSize(width: tvOSTalkViewCell.THUMB_WIDTH * 1.3, height: 230)
        layout.headerReferenceSize = CGSize(width: 1000, height: 200)
        layout.minimumLineSpacing  = 20
        layout.scrollDirection     = .vertical
        
        self.tabBarController.setViewControllers([tvOSCollectionViewController(collectionViewLayout: layout)], animated: false)
    }

}
