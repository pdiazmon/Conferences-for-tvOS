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
  
    weak var coordinator: MainCoordinator?
    private var currentTalk: TalkModel?
    
    private weak var profileImageDownloadOperation: Operation?
    private weak var thumbnailImageDownloadOperation: Operation?
    private var PROFILEIMG_HEIGHTWIDTH: CGFloat = 0
    private var THUMB_WIDTH: CGFloat = 0

    private lazy var talkTitle: UILabel = {
        var title = UILabel()
      
        title.font          = .systemFont(ofSize: 35, weight: .bold)
        title.textColor     = .primaryText
        title.lineBreakMode = .byTruncatingTail
        title.numberOfLines = 1
        
        return title
        
    }()
    
    private lazy var talkDetails: UILabel = {
        var details = UILabel()
      
        details.font          = .systemFont(ofSize: 23, weight: .medium)
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
//        thumbnailImageView.topToSuperview(offset: 20)
        
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
      
        name.font          = .systemFont(ofSize: 27, weight: .medium)
        name.textColor     = .primaryText
        name.lineBreakMode = .byTruncatingTail
        name.numberOfLines = 1
        
        return name
        
    }()
    
    private lazy var twitterAccount: UILabel = {
        var twitter = UILabel()
      
        twitter.font          = .systemFont(ofSize: 26, weight: .medium)
        twitter.textColor     = .tertiaryText
        twitter.lineBreakMode = .byTruncatingTail
        twitter.numberOfLines = 1
        
        return twitter
    }()
    
    private lazy var profileAbout: UILabel = {
        var about = UILabel()
      
        about.font          = .systemFont(ofSize: 23, weight: .medium)
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
    
    private var buttonParallaxEffectOptions: ParallaxEffectOptions?
    
    var playButton: UIButton = {
        var button = UIButton()

        button.setTitle("Play", for: .normal)
        button.addTarget(self, action: #selector(didSelectPlay), for: UIControl.Event.primaryActionTriggered)
        button.layer.cornerRadius = 15.0
        button.clipsToBounds      = true
        button.contentEdgeInsets  = UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40)
        button.titleLabel?.font   = .systemFont(ofSize: 35, weight: .medium)
        
        return button
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
        
        setParallaxEffect()
    }
    
    private func setup() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
        
        self.view.addSubview(stackTalk)
        self.view.addSubview(line1)
        self.view.addSubview(stackSpeaker)
        self.view.addSubview(line2)
        self.view.addSubview(playButton)
        
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
        
        self.playButton.topToBottom(of: line2, offset: 30)
        self.playButton.centerXToSuperview()
    }
    
    func render(talk: TalkModel) {
        
        self.currentTalk = talk
        
        calculateImagesSizes()
        
        self.talkTitle.text      = talk.title
        self.talkDetails.text    = talk.details
        self.profileName.text    = talk.speaker.firstname + " " + talk.speaker.lastname
        self.twitterAccount.text = "@" + (talk.speaker.twitter ?? "")
        self.profileAbout.text   = talk.speaker.about
      
        guard let profileImageUrl = URL(string: talk.speaker.image) else { return }
        self.profileImageDownloadOperation?.cancel()

        self.profileImageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: profileImageUrl, thumbnailHeight: PROFILEIMG_HEIGHTWIDTH) { [weak self] url, _, img in
            guard url == profileImageUrl, img != nil else { return }

            self?.profilePicture.image = img?.resized(toWidth: self?.PROFILEIMG_HEIGHTWIDTH ?? 0)
        }

        guard let thumbnailImageUrl = URL(string: talk.previewImage) else { return }
        self.thumbnailImageDownloadOperation?.cancel()
        
        self.thumbnailImageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: thumbnailImageUrl, thumbnailHeight: THUMB_WIDTH) { [weak self] url, _, img in
            guard url == thumbnailImageUrl, img != nil else { return }
            
            self?.thumbnailImageView.image = img?.resized(toWidth: self?.THUMB_WIDTH ?? 0)
        }
    }
    
    private func calculateImagesSizes() {
        guard (THUMB_WIDTH == 0 || PROFILEIMG_HEIGHTWIDTH == 0) else { return }
        
        THUMB_WIDTH            = self.view.bounds.width * 0.18
        PROFILEIMG_HEIGHTWIDTH = self.view.bounds.width * 0.07
    }

}

extension tvOSDetailViewController {

    @objc func didSelectPlay() {
        guard let talk = self.currentTalk else { return }
        
      self.coordinator?.playTalk(talk: talk)
    }
}

// MARK: - ParallaxEffect

extension tvOSDetailViewController {

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [unowned self] in
            // Add parallax effect only to controls inside this view controller
            if let nextFocusedView = context.nextFocusedView , nextFocusedView.isDescendant(of: self.view) {
                switch context.nextFocusedView {
                case is UIButton:
                    // Custom parallax effect for the button
                    var buttonParallaxEffectOptions = self.buttonParallaxEffectOptions!
                    self.playButton.addParallaxMotionEffects(with: &buttonParallaxEffectOptions)
                default:
                    // For the anyView use default options
                    context.nextFocusedView?.addParallaxMotionEffects()
                }
            }

            // Remove parallax effect for the view that lost focus
            switch context.previouslyFocusedView {
            case is UIButton:
                // Because anyButton uses custom glow container we have to pass it to remove parallax effect correctly
                self.playButton.removeParallaxMotionEffects(with: self.buttonParallaxEffectOptions!)
            default:
                context.previouslyFocusedView?.removeParallaxMotionEffects()
            }

            }, completion: nil)
    }
    
    private func setParallaxEffect() {
        // Define custom glow for the parallax effect
        let customGlowContainer = UIView(frame: playButton.bounds)
        customGlowContainer.clipsToBounds = true
        customGlowContainer.backgroundColor = UIColor.clear
        playButton.subviews.first?.subviews.last?.addSubview(customGlowContainer)

        buttonParallaxEffectOptions = ParallaxEffectOptions(glowContainerView: customGlowContainer)
        
        // Add gray background color to make glow effect be more visible
        playButton.setBackgroundImage(getImageWithColor(UIColor.lightGray, size: playButton.bounds.size), for: UIControl.State())
    }

    
    func getImageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
