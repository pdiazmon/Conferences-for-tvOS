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
    private var vcList: tvOSCollectionViewController!
    private var vcDetail: tvOSDetailViewController!
    private var vcPlayer: tvOSPlayerViewController!

    init() {
        self.tabBarController     = UITabBarController()
        self.navigationController = UINavigationController()
    }

    func start() {
        self.tabBarController.tabBar.tintColor    = .primaryText
        self.tabBarController.tabBar.barTintColor = .elementBackground
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset        = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize            = CGSize(width: tvOSTalkViewCell.THUMB_WIDTH * 1.5, height: 375)
        layout.headerReferenceSize = CGSize(width: 1000, height: 250)
        layout.minimumLineSpacing  = 50
        layout.scrollDirection     = .vertical
        
        vcList = tvOSCollectionViewController(collectionViewLayout: layout)
        vcList.coordinator = self
        self.navigationController.setViewControllers([vcList], animated: true)
        
        self.tabBarController.setViewControllers([navigationController], animated: false)
        
        vcDetail = tvOSDetailViewController()
        vcDetail.coordinator = self
        
        vcPlayer = tvOSPlayerViewController()
        vcPlayer.coordinator = self
    }
    
    func showTalkDetails(talk: TalkModel) {
        vcDetail?.render(talk: talk)
        navigationController.pushViewController(vcDetail, animated: true)
    }
    
    func playTalk(talk: TalkModel) {
        PlaybackViewModel.getVideoUrl(talk: talk) { (url) in
            guard let url = url else { return }

            DispatchQueue.main.async {
                self.playbackViewModel = PlaybackViewModel(talk: talk, url: url)
                
                self.navigationController.pushViewController(self.vcPlayer, animated: true)
                
                self.vcPlayer.player = self.playbackViewModel?.player
                self.vcPlayer.player?.play()
            }
        }
    }
}

extension MainCoordinator {
    func reloadCollection() {
        vcList.reloadTableView()
    }
}

