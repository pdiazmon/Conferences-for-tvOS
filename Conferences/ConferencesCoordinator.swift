//
//  MainCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import AVKit

enum ConferencesCoordinatorMode {
    case allConferences
    case watchList
    case continueWatching
}

final class ConferencesCoordinator: Coordinator {
    private var mode: ConferencesCoordinatorMode
    
    lazy var vc: UIViewController = {
        let navigationController = UINavigationController(rootViewController: vcList)
        
        return navigationController
    }()
    
    lazy var navigationController: UINavigationController = {
        return (vc as! UINavigationController)
    }()
    
    lazy var vcList: tvOSCollectionViewController = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset        = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize            = CGSize(width: tvOSTalkViewCell.THUMB_WIDTH * 1.5, height: 375)
        layout.headerReferenceSize = CGSize(width: 1000, height: 250)
        layout.minimumLineSpacing  = 50
        layout.scrollDirection     = .vertical
        
        var vc = tvOSCollectionViewController(collectionViewLayout: layout, mode: self.mode)
        vc.coordinator = self
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32.0)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
        
        switch self.mode {
        case .allConferences:
            vc.title = "Conferences"
            vc.tabBarItem = UITabBarItem(title: "Conferences", image: nil, selectedImage: nil)
        case .watchList:
            vc.title = "Watch List"
            vc.tabBarItem = UITabBarItem(title: "Watch List", image: nil, selectedImage: nil)
        case .continueWatching:
            vc.title = "Continue Watching"
            vc.tabBarItem = UITabBarItem(title: "Continue Watching", image: nil, selectedImage: nil)
        }
        
        return vc
    }()
    
    private var playbackViewModel: PlaybackViewModel?
    
    private lazy var vcDetail: tvOSDetailViewController = {
        var vc = tvOSDetailViewController()
        
        vc.coordinator = self
        
        return vc
    }()
    
    private lazy var vcPlayer: tvOSPlayerViewController = {
        var vc = tvOSPlayerViewController()
        
        vc.coordinator = self
        vc.mode        = mode
        
        return vc
    }()
    
    private lazy var vcPlayOptions: TalkPlayOptionsViewController = {
        var vc = TalkPlayOptionsViewController()
        
        vc.coordinator = self
        
        return vc
    }()
    
    init(mode: ConferencesCoordinatorMode = .allConferences) {
        self.mode = mode
    }

    func start() {
    }
    
    func showTalkDetails(talk: TalkModel) {
        vcDetail.render(talk: talk)
        navigationController.pushViewController(vcDetail, animated: true)
    }
    
    func playTalk(talk: TalkModel) {
        if let progress = talk.progress, progress.currentPosition > 0 {
            playTalkWithOptions(talk: talk)
        }
        else {
            playTalkFromCurrentPosition(talk: talk)
        }
    }
    
    func playTalkFromCurrentPosition(talk: TalkModel) {
        PlaybackViewModel.getVideoUrl(talk: talk) { (url) in
            guard let url = url else { return }
            
            DispatchQueue.main.async {
                self.playbackViewModel = PlaybackViewModel(talk: talk, url: url)
                
                if (self.navigationController.topViewController is TalkPlayOptionsViewController) {
                    self.navigationController.popViewController(animated: true)
                }
                
                self.navigationController.pushViewController(self.vcPlayer, animated: true)
                
                self.vcPlayer.player = self.playbackViewModel?.player
                self.vcPlayer.player?.play()
            }
        }
    }
    
    func playTalkFromBeginning(talk: TalkModel) {
        talk.initializeProgress()
        self.playTalkFromCurrentPosition(talk: talk)
    }
  
    private func playTalkWithOptions(talk: TalkModel) {
        vcPlayOptions.render(talk: talk)
        navigationController.pushViewController(vcPlayOptions, animated: true)
    }
    
}

