//
//  tvOSDetailViewController.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 14/05/2019.
//  Copyright © 2019 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit
import ParallaxView

class tvOSDetailViewController: UIViewController {
  
    weak var coordinator: ConferencesCoordinator?
    private var currentTalk: TalkModel?
    
    private weak var profileImageDownloadOperation: Operation?
    private weak var thumbnailImageDownloadOperation: Operation?
    private var PROFILEIMG_HEIGHTWIDTH: CGFloat = 0
    private var THUMB_WIDTH: CGFloat = 0
    private let BUTTON_HEIGHTWIDTH: CGFloat = 70
    private let BUTTON_IMAGESIZE: CGFloat = 50
    private let BUTTON_CORNERRADIUS: CGFloat = 10
    private let BUTTON_EDGEINSET: CGFloat = 7

    private lazy var talkTitle: UILabel = {
        var title = UILabel()
      
        title.font          = .systemFont(ofSize: 40, weight: .bold)
        title.textColor     = .primaryText
        title.lineBreakMode = .byTruncatingTail
        title.numberOfLines = 1
        
        return title
        
    }()
    
    private lazy var talkDetails: UILabel = {
        var details = UILabel()
      
        details.font          = .systemFont(ofSize: 28, weight: .medium)
        details.textColor     = .secondaryText
        details.lineBreakMode = .byTruncatingTail
        details.numberOfLines = 0
        
        return details
    }()
    
    private lazy var stackTalkTitle: UIStackView = {
        var talk = UIStackView(arrangedSubviews: [talkTitle, talkDetails])
        
        talk.axis      = .vertical
        talk.spacing   = 10
        talk.alignment = .leading
        
        return talk
    }()
    
    lazy var thumbnailImageView: UIImageView = {
        let thumb = UIImageView()
        
        thumb.contentMode = .scaleAspectFit
        
        return thumb
    }()
    
    private lazy var stackTalk: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [stackTalkTitle, thumbnailImageView])
        
        thumbnailImageView.trailingToSuperview()
        
        stack.axis      = .horizontal
        stack.spacing   = 20
        stack.alignment = .top
        
        return stack
    }()
    
    private lazy var line1: UIView = {
        var line = UIView()
        
        line.backgroundColor = .white
        line.height(2)
        
        return line
    }()
    
    private lazy var profilePicture: UIImageView = {
        let picture = UIImageView()

        picture.layer.borderWidth  = 2
        picture.layer.borderColor  = UIColor.activeColor.cgColor
        picture.clipsToBounds      = true
        
        calculateImagesSizes()
        picture.layer.cornerRadius = PROFILEIMG_HEIGHTWIDTH / 2
        
        return picture
    }()
    
    private lazy var profileName: UILabel = {
        var name = UILabel()
      
        name.font          = .systemFont(ofSize: 35, weight: .medium)
        name.textColor     = .primaryText
        name.lineBreakMode = .byTruncatingTail
        name.numberOfLines = 1
        
        return name
        
    }()
    
    private lazy var twitterAccount: UILabel = {
        var twitter = UILabel()
      
        twitter.font          = .systemFont(ofSize: 30, weight: .medium)
        twitter.textColor     = .tertiaryText
        twitter.lineBreakMode = .byTruncatingTail
        twitter.numberOfLines = 1
        
        return twitter
    }()
    
    private lazy var profileAbout: UILabel = {
        var about = UILabel()
      
        about.font          = .systemFont(ofSize: 28, weight: .medium)
        about.textColor     = .secondaryText
        about.lineBreakMode = .byTruncatingTail
        about.numberOfLines = 0
        
        return about
    }()
    
    private lazy var stackSpeakerText: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [profileName, twitterAccount, profileAbout])
        
        stack.axis      = .vertical
        stack.spacing   = 10
        stack.alignment = .leading
        
        return stack
    }()
    
    private lazy var stackSpeaker: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [profilePicture, stackSpeakerText])
        
        stack.axis      = .horizontal
        stack.spacing   = 20
        stack.alignment = .top
        
        return stack
    }()
    
    private lazy var line2: UIView = {
        var line = UIView()
        
        line.backgroundColor = .white
        line.height(1.5)
        
        return line
    }()
    
    private lazy var playButton: UIButton = {
        var button = UIButton()
        
        button.tintColor          = .white
        button.layer.cornerRadius = BUTTON_CORNERRADIUS
        button.layer.borderColor  = UIColor.white.cgColor
        button.imageEdgeInsets    = UIEdgeInsets(top: BUTTON_EDGEINSET, left: BUTTON_EDGEINSET, bottom: BUTTON_EDGEINSET, right: BUTTON_EDGEINSET)
        button.height(BUTTON_HEIGHTWIDTH)
        button.width(BUTTON_HEIGHTWIDTH)
        button.addTarget(self, action: #selector(didSelectPlay), for: UIControl.Event.primaryActionTriggered)
        
        return button
    }()

    
    private lazy var watchlistButton: UIButton = {
        var button = UIButton()
        
        button.tintColor          = .white
        button.layer.cornerRadius = BUTTON_CORNERRADIUS
        button.layer.borderColor  = UIColor.white.cgColor
        button.imageEdgeInsets    = UIEdgeInsets(top: BUTTON_EDGEINSET, left: BUTTON_EDGEINSET, bottom: BUTTON_EDGEINSET, right: BUTTON_EDGEINSET)
        button.height(BUTTON_HEIGHTWIDTH)
        button.width(BUTTON_HEIGHTWIDTH)
        button.addTarget(self, action: #selector(didSelectWatchlist), for: UIControl.Event.primaryActionTriggered)
        
        return button
    }()

    private lazy var watchButton: UIButton = {
        var button = UIButton()
        
        button.tintColor          = .white
        button.layer.cornerRadius = BUTTON_CORNERRADIUS
        button.layer.borderColor  = UIColor.white.cgColor
        button.imageEdgeInsets    = UIEdgeInsets(top: BUTTON_EDGEINSET, left: BUTTON_EDGEINSET, bottom: BUTTON_EDGEINSET, right: BUTTON_EDGEINSET)
        button.height(BUTTON_HEIGHTWIDTH)
        button.width(BUTTON_HEIGHTWIDTH)
        button.addTarget(self, action: #selector(didSelectWatch), for: UIControl.Event.primaryActionTriggered)
        
        return button
    }()

    private lazy var stackButtons: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [playButton, watchlistButton, watchButton])
        
        stack.axis      = .horizontal
        stack.spacing   = 50
        stack.alignment = .center
        
        return stack
    }()
    
    private lazy var tooltipLabel: UILabel = {
        var label = UILabel()
        
        label.font          = .systemFont(ofSize: 25, weight: .medium)
        label.textColor     = .primaryText
        label.textAlignment = .center

        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculateImagesSizes()
        
        setup()
        layout()
    }
    
    override func viewDidLayoutSubviews() {
        talkDetails.sizeToFit()
        profileName.sizeToFit()
        profileAbout.sizeToFit()
    }
    
    private func setup() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
        
        self.view.addSubview(stackTalk)
        self.view.addSubview(line1)
        self.view.addSubview(stackSpeaker)
        self.view.addSubview(line2)
        self.view.addSubview(stackButtons)
        self.view.addSubview(tooltipLabel)
        
        self.view.backgroundColor = .panelBackground
    }
    
    private func layout() {
        let RIGHTLEFT_OFFSET = self.view.bounds.width * 0.1

        self.stackTalk.topToSuperview(offset: 60)
        self.stackTalk.leadingToSuperview(offset: RIGHTLEFT_OFFSET)
        self.stackTalk.trailingToSuperview(offset: RIGHTLEFT_OFFSET)

        self.line1.topToBottom(of: stackTalk, offset: 30)
        self.line1.leading(to: stackTalk)
        self.line1.trailingToSuperview(offset: RIGHTLEFT_OFFSET)
        
        self.stackSpeaker.topToBottom(of: line1, offset: 30)
        self.stackSpeaker.leadingToSuperview(offset: RIGHTLEFT_OFFSET)
        self.stackSpeaker.trailingToSuperview(offset: RIGHTLEFT_OFFSET)
        
        self.line2.topToBottom(of: stackSpeaker, offset: 30)
        self.line2.leading(to: line1)
        self.line2.trailing(to: line1)
        
        self.stackButtons.topToBottom(of: line2, offset: 30)
        self.stackButtons.leading(to: line2)
        
        self.tooltipLabel.bottomToSuperview(offset: -15)
        self.tooltipLabel.centerXToSuperview()
        self.tooltipLabel.widthToSuperview()
    }
    
    func render(talk: TalkModel) {
        
        self.currentTalk = talk
        
        calculateImagesSizes()
        
        DispatchQueue.main.async { [weak self] in
            self?.talkTitle.text      = talk.title
            self?.talkDetails.text    = talk.details
            self?.profileName.text    = talk.speaker.firstname + " " + talk.speaker.lastname
            if let twitter = talk.speaker.twitter, !(twitter.isEmpty) {
                self?.twitterAccount.text = "@" + twitter
            }
            self?.profileAbout.text = talk.speaker.about

            self?.playButton.setImage(self?.getButtonImage(named: "play"), for: .normal)
            self?.watchlistButton.setImage(self?.watchlistImage(), for: .normal)
            self?.watchButton.setImage(self?.watchImage(), for: .normal)
        }
      
        guard let profileImageUrl = URL(string: talk.speaker.image) else { return }
        self.profileImageDownloadOperation?.cancel()

        self.profileImageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: profileImageUrl, thumbnailHeight: PROFILEIMG_HEIGHTWIDTH) { [weak self] url, _, img in
            guard url == profileImageUrl, img != nil else { return }

            DispatchQueue.main.async { [weak self] in
                self?.profilePicture.image = img?.resized(toWidth: self?.PROFILEIMG_HEIGHTWIDTH ?? 0)
            }
        }

        guard let thumbnailImageUrl = URL(string: talk.previewImage) else { return }
        self.thumbnailImageDownloadOperation?.cancel()
        
        self.thumbnailImageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: thumbnailImageUrl, thumbnailHeight: THUMB_WIDTH) { [weak self] url, _, img in
            guard url == thumbnailImageUrl, img != nil else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.thumbnailImageView.image = img?.resized(toWidth: self?.THUMB_WIDTH ?? 0)
            }
        }
    }
    
    private func calculateImagesSizes() {
        guard (THUMB_WIDTH == 0 || PROFILEIMG_HEIGHTWIDTH == 0) else { return }
        
        THUMB_WIDTH            = self.view.bounds.width * 0.25
        PROFILEIMG_HEIGHTWIDTH = self.view.bounds.width * 0.07
    }

}

// MARK: - ParallaxEffect

extension tvOSDetailViewController {

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [unowned self] in
            // Remove parallax effect for the view that lost focus
            if let prev = (context.previouslyFocusedItem as? UIButton) {
                if (prev.isDescendant(of: self.stackButtons)) {
                    prev.removeParallaxMotionEffects()
                    prev.layer.borderWidth = 0
                    self.removeButtonTooltip()
                }
            }

            if let next = (context.nextFocusedView as? UIButton) {
                if (next.isDescendant(of: self.stackButtons)) {
                    next.addParallaxMotionEffects()
                    next.layer.borderWidth = 3
                    self.setButtonTooltip(for: next)
                }
            }

        }, completion: nil)
    }
}


// MARK: - Buttons functions

extension tvOSDetailViewController {
    
    @objc func didSelectPlay() {
        guard let talk = self.currentTalk else { return }
        
        coordinator?.playTalk(talk: talk)        
    }
    
    @objc private func didSelectWatchlist() {
        guard var talk = self.currentTalk else { return }
        
        talk.onWatchlist.toggle()
        
        watchlistButton.setImage(watchlistImage(), for: .normal)
        setButtonTooltip(for: watchlistButton)
        
        var tag = TagModel(title: "Watchlist", query: "realm_watchlist", isActive: talk.onWatchlist)
        TagSyncService.shared.handleStoredTag(&tag)
      
        NotificationCenter.default.post(.init(name: .watchlistUpdated, object: true))
    }
    
    @objc private func didSelectWatch() {
        guard var talk = self.currentTalk else { return }
        
        talk.watched.toggle()
        
        watchButton.setImage(watchImage(), for: .normal)
        setButtonTooltip(for: watchButton)
        
        var tag = TagModel(title: "Confinue watching", query: "realm_continue", isActive: false)
        TagSyncService.shared.handleStoredTag(&tag)
        
        NotificationCenter.default.post(.init(name: .continueWatchingUpdated, object: true))
    }
    
    private func watchlistImage() -> UIImage? {
        guard var talk = self.currentTalk else { return nil }
        
        return talk.onWatchlist ? getButtonImage(named: "watchlist_filled") : getButtonImage(named: "watchlist")
    }
    
    private func watchImage() -> UIImage? {
        guard var talk = self.currentTalk else { return nil }
        
        return talk.watched ? getButtonImage(named: "watch_filled") : getButtonImage(named: "watch")
    }
    
    private func getButtonImage(named: String) -> UIImage? {
        return UIImage(named: named)?.resized(to: BUTTON_IMAGESIZE)
    }
    
    private func setButtonTooltip(for button: UIButton) {
        var tooltip: String = ""
        
        if (button == self.playButton) {
            tooltip = "Play talk"
        }
        else if (button == self.watchButton) {
            if (self.currentTalk?.watched ?? false) {
                tooltip = "Set talk to unwatched"
            }
            else {
                tooltip = "Set talk to watched"
            }
        }
        else if (button == self.watchlistButton) {
            if (self.currentTalk?.onWatchlist ?? false) {
                tooltip = "Remove talk from watchlist"
            }
            else {
                tooltip = "Add talk to watchlist"
            }
        }
        
        DispatchQueue.main.async {
            self.tooltipLabel.text = tooltip
        }
    }
    
    private func removeButtonTooltip() {
        DispatchQueue.main.async {
            self.tooltipLabel.text = ""
        }
    }
}
