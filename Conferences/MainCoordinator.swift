//
//  MainCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVKit
import YTVimeoExtractor

final class MainCoordinator {
    let tabBarController: UITabBarController
    private var navigationController: UINavigationController

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
        if (talk.source == .youtube) {
            playYouTubeVideo(talk: talk)
        }
        else if (talk.source == .vimeo) {
            playVimeoVideo(talk: talk)
        }
    }
}

extension MainCoordinator {
    
    private func playYouTubeVideo(talk: TalkModel) {
        XCDYouTubeClient.default().getVideoWithIdentifier(talk.videoId) { video, error in
            if (video != nil) {
                let streamURLs = video?.streamURLs
                var streamURL: URL?
                
                if (streamURLs?[XCDYouTubeVideoQualityHTTPLiveStreaming] != nil) { streamURL = streamURLs?[XCDYouTubeVideoQualityHTTPLiveStreaming] }
                else if (streamURLs?[XCDYouTubeVideoQuality.HD720.rawValue] != nil) { streamURL = streamURLs?[XCDYouTubeVideoQuality.HD720.rawValue] }
                else if (streamURLs?[XCDYouTubeVideoQuality.medium360.rawValue] != nil) { streamURL = streamURLs?[XCDYouTubeVideoQuality.medium360.rawValue] }
                else if (streamURLs?[XCDYouTubeVideoQuality.small240.rawValue] != nil) { streamURL = streamURLs?[XCDYouTubeVideoQuality.small240.rawValue] }
                
                if let streamURL = streamURL {
                    self.playVideo(url: streamURL)
                }
            }
        }
    }
    
    private func playVimeoVideo(talk: TalkModel) {
        YTVimeoExtractor.shared().fetchVideo(withVimeoURL: talk.url, withReferer: nil) { (video:YTVimeoVideo?, error:Error?) in
            
            if let streamUrls = video?.streamURLs {
                var streamURL: String?
                var streams : [String:String] = [:]
                
                for (key,value) in streamUrls {
                    streams["\(key)"] = "\(value)"
                }
                
                if let large = streams["720"] { streamURL = large }
                else if let high = streams["480"] { streamURL = high }
                else if let medium = streams["360"] { streamURL = medium }
                else if let low = streams["270"] { streamURL = low }
                
                if let url = streamURL, let videoURL = URL(string: url) {
                    self.playVideo(url: videoURL)
                }
            }
        }
    }
    
    private func playVideo(url: URL) {
        let playerViewController = AVPlayerViewController()

        navigationController.pushViewController(playerViewController, animated: true)

        weak var weakPlayerViewController: AVPlayerViewController? = playerViewController
        weakPlayerViewController?.player = AVPlayer(url: url)
        weakPlayerViewController?.player?.play()
    }
}
