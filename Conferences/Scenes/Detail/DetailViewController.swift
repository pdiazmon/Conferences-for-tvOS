
//
//  DetailViewController.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
//import YoutubeKit
import TinyConstraints

class DetailViewController: UIViewController {
    var talk: TalkModel?

    private weak var imageDownloadOperation: Operation?

    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceHorizontal = false
        v.contentInsetAdjustmentBehavior = .never

        return v
    }()

    private lazy var playerContainer: UIView = {
        let v = UIView(frame: .zero)
        v.addSubview(previewImage)
        v.addSubview(playButton)
        v.backgroundColor = .black
        previewImage.edgesToSuperview()
        playButton.centerInSuperview()

        previewImage.contentMode = .scaleAspectFit

        return v
    }()

    private lazy var previewImage = UIImageView()
//    private var player: YTSwiftyPlayer?

    private lazy var detailSummaryViewController = DetailSummaryViewController()

    private lazy var playButton: UIButton = {
        let b = UIButton()
        b.setTitle("Play", for: .normal)
        b.addTarget(self, action: #selector(didSelectPlay), for: .touchUpInside)
        b.backgroundColor = UIColor.elementBackground
        b.layer.cornerRadius = 7
        b.width(60)

        return b
    }()

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.playerContainer, self.detailSummaryViewController.view])

        v.axis = .vertical
        v.spacing = 20

        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    private func configureView() {
        view.backgroundColor = .panelBackground
        view.addSubview(scrollView)
        scrollView.edgesToSuperview()
        scrollView.addSubview(stackView)
        stackView.edgesToSuperview()
        stackView.width(to: view)
        addChild(detailSummaryViewController)
        playerContainer.height(to: view, offset: -view.frame.height * 0.3)
    }

    func configureView(with talk: TalkModel) {
        self.talk = talk
        detailSummaryViewController.configureView(with: talk)
//        player?.clearVideo()
//        player?.removeFromSuperview()
//        player = nil
        guard let imageUrl = URL(string: talk.previewImage) else { return }

        self.imageDownloadOperation?.cancel()

        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 150) { [weak self] url, original, _ in
            guard url == imageUrl, original != nil else { return }

            self?.previewImage.image = original
        }
    }

    func scrollToTop() {
        scrollView.setContentOffset(.zero, animated: false)
    }

    @objc func didSelectPlay() {
//        player = YTSwiftyPlayer(
//            frame: .zero,
//            playerVars: [.videoID(talk!.videoId), .playsInline(false), .showControls(.show), .autoplay(true), .showFullScreenButton(true)])
//
//        guard let player = player else { return }
//        playerContainer.addSubview(player)
//        player.edgesToSuperview()
//        player.autoplay = true
//        player.delegate = self
//        player.loadPlayer()
    }
}

//extension DetailViewController: YTSwiftyPlayerDelegate {
//    func playerReady(_ player: YTSwiftyPlayer) {
//        player.playVideo()
//    }
//}

