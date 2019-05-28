//
//  TalkPlayOptionsViewController.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 27/05/2019.
//  Copyright © 2019 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit

class TalkPlayOptionsViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    var currentTalk: TalkModel?
    
    private let BUTTON_HEIGHT: CGFloat    = 70
    private let BUTTON_EDGEINSET: CGFloat = 15
    private weak var thumbnailImageDownloadOperation: Operation?
    
    private lazy var blurEffectView: UIVisualEffectView = {
        var blur = UIVisualEffectView()
        
        blur.effect           = UIBlurEffect(style: UIBlurEffect.Style.extraDark)
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return blur
    }()
    
    private lazy var backgroundImage: UIImageView = {
        var imgview = UIImageView()
        
        imgview.contentMode = .scaleAspectFill
        
        return imgview
    }()
    
    private lazy var playButton: UIButton = {
        var button = UIButton()
        
        button.titleLabel?.font           = .systemFont(ofSize: 30, weight: .medium)
        button.titleLabel?.textColor      = .primaryText
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets            = UIEdgeInsets(top: BUTTON_EDGEINSET, left: BUTTON_EDGEINSET, bottom: BUTTON_EDGEINSET, right: BUTTON_EDGEINSET)
        button.layer.borderColor          = UIColor.white.cgColor
        button.height(self.BUTTON_HEIGHT)
        
        button.addTarget(self, action: #selector(didSelectPlay), for: UIControl.Event.primaryActionTriggered)
        
        button.setTitle("Play from beginning", for: .normal)
        
        
        return button
    }()
    
    private lazy var resumeButton: UIButton = {
        var button = UIButton()
        
        button.titleLabel?.font           = .systemFont(ofSize: 30, weight: .medium)
        button.titleLabel?.textColor      = .primaryText
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets            = UIEdgeInsets(top: BUTTON_EDGEINSET, left: BUTTON_EDGEINSET, bottom: BUTTON_EDGEINSET, right: BUTTON_EDGEINSET)
        button.layer.borderColor          = UIColor.white.cgColor
        button.height(self.BUTTON_HEIGHT)
        
        button.addTarget(self, action: #selector(didSelectResume), for: UIControl.Event.primaryActionTriggered)
        
        return button
    }()
    
    private lazy var thumbnail: UIImageView = {
        var imageview = UIImageView()
        
        imageview.contentMode  = .scaleAspectFit
        
        return imageview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
    }

    private func setup() {
        self.view.addSubview(backgroundImage)
        self.view.addSubview(blurEffectView)
        self.view.addSubview(playButton)
        self.view.addSubview(resumeButton)
        self.view.addSubview(thumbnail)
    }
    
    private func layout() {
        let leadingtrailing = self.view.bounds.width * 0.1
        let space: CGFloat  = 50
        let thumbWidth      = self.view.bounds.width * 0.4 - space
        
        backgroundImage.frame = self.view.bounds
        
        thumbnail.leadingToSuperview(offset: leadingtrailing)
        thumbnail.width(thumbWidth)
        thumbnail.centerYToSuperview()
        
        playButton.trailingToSuperview(offset: leadingtrailing)
        playButton.leadingToTrailing(of: thumbnail, offset: space)
        playButton.centerYToSuperview(offset: -(20+self.BUTTON_HEIGHT/2))
        
        resumeButton.trailingToSuperview(offset: leadingtrailing)
        resumeButton.leadingToTrailing(of: thumbnail, offset: space)
        resumeButton.centerYToSuperview(offset: (20+self.BUTTON_HEIGHT/2))
        
        blurEffectView.frame = view.bounds
        
        self.view.backgroundColor = .panelBackground
    }
    
    func render(talk: TalkModel) {
        self.currentTalk = talk
        
        let resumeText = "Resume from " + String(talk.progress?.currentPositionToHoursMinutesSeconds() ?? "")
        DispatchQueue.main.async { [weak self] in
            self?.resumeButton.setTitle(resumeText, for: .normal)
        }
        
        let THUMB_WIDTH = self.view.bounds.width * 0.4
        
        guard let thumbnailImageUrl = URL(string: talk.previewImage) else { return }
        self.thumbnailImageDownloadOperation?.cancel()
        
        self.thumbnailImageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: thumbnailImageUrl, thumbnailHeight: THUMB_WIDTH) { [weak self] url, _, img in
            guard url == thumbnailImageUrl, img != nil else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.thumbnail.image       = img?.resized(toWidth: THUMB_WIDTH)
                self?.backgroundImage.image = img
            }
        }
    }
}


extension TalkPlayOptionsViewController {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            if let prev = (context.previouslyFocusedItem as? UIButton) {
                prev.layer.borderWidth = 0
            }
            
            if let next = (context.nextFocusedView as? UIButton) {
                next.layer.borderWidth = 3
            }
            
        }, completion: nil)
    }

}

extension TalkPlayOptionsViewController {
    
    @objc func didSelectPlay() {
        guard let talk = self.currentTalk else { return }
        
        self.coordinator?.playTalkFromBeginning(talk: talk)
    }
    
    @objc func didSelectResume() {
        guard let talk = self.currentTalk else { return }

        self.coordinator?.playTalkFromCurrentPosition(talk: talk)
    }
}
