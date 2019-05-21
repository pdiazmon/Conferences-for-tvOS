//
//  MainCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import AVKit

final class MainCoordinator {
    let tabBarController: UITabBarController
    private var navigationController: UINavigationController
    private var playbackViewModel: PlaybackViewModel?

    init() {
        self.tabBarController     = UITabBarController()
        self.navigationController = UINavigationController()
    }

    func start() {
        self.tabBarController.tabBar.tintColor    = .primaryText
        self.tabBarController.tabBar.barTintColor = .elementBackground
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset        = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize            = CGSize(width: tvOSTalkViewCell.THUMB_WIDTH * 1.3, height: 230)
        layout.headerReferenceSize = CGSize(width: 1000, height: 200)
        layout.minimumLineSpacing  = 20
        layout.scrollDirection     = .vertical
        
        let vc = tvOSCollectionViewController(collectionViewLayout: layout)
        vc.coordinator = self
        self.navigationController.setViewControllers([vc], animated: true)
        
        self.tabBarController.setViewControllers([navigationController], animated: false)
    }
    
    func showTalkDetails(talk: TalkModel) {
        let vc = tvOSDetailViewController()
        vc.render(talk: talk)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func playTalk(talk: TalkModel) {
        PlaybackViewModel.getVideoUrl(talk: talk) { (url) in
            guard let url = url else { return }

            DispatchQueue.main.async {
                self.playbackViewModel = PlaybackViewModel(talk: talk, url: url)
                
                let playerViewController = AVPlayerViewController()
                self.navigationController.pushViewController(playerViewController, animated: true)
                
                playerViewController.player = self.playbackViewModel?.player
                playerViewController.player?.play()
            }
        }
    }
}
