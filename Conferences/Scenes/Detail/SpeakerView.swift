//
//  SpeakerView.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import TinyConstraints

class SpeakerView: UIView {

    private var speaker: SpeakerModel?
    private weak var imageDownloadOperation: Operation?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var profilePicture: UIImageView = {
        let v = UIImageView()

        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.activeColor.cgColor
        v.layer.cornerRadius = 30
        v.clipsToBounds = true
        v.height(60)
        v.width(60)

        return v
    }()

    private lazy var aboutLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryText


        l.lineBreakMode = NSLineBreakMode.byTruncatingTail
        l.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        l.allowsDefaultTighteningForTruncation = true
        l.numberOfLines = 20

        return l
    }()

    private lazy var twitterButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.tintColor = .white
        b.setImage(UIImage(named: "twitter"), for: .normal)
        b.addTarget(self, action: #selector(openTwitter), for: .touchUpInside)

        return b
    }()

    private lazy var githubButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.tintColor = .white
        b.setImage(UIImage(named: "github"), for: .normal)
        b.addTarget(self, action: #selector(openGithub), for: .touchUpInside)

        return b
    }()


    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .primaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    private lazy var socialMediaStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.twitterButton, self.githubButton])

        v.distribution = .fill
        v.spacing = 10

        return v
    }()

    private lazy var textStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])

        v.axis = .vertical
        v.alignment = .leading
        v.distribution = .fill

        return v
    }()

    private lazy var informationStackView: UIStackView = {
        let spacing = UIView()
        spacing.backgroundColor = UIColor.activeColor
        spacing.height(1)

        let v = UIStackView(arrangedSubviews: [self.textStackView, spacing, self.socialMediaStackView])

        spacing.widthToSuperview()
        v.axis = .vertical
        v.alignment = .leading
        v.spacing = 10

        return v
    }()

    private lazy var topStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.profilePicture, self.informationStackView])

        v.alignment = .top
        v.distribution = .fill
        v.spacing = 15

        return v
    }()

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.topStackView, self.aboutLabel])

        self.topStackView.width(to: v)

        v.alignment = .top
        v.axis = .vertical
        v.distribution = .equalCentering
        v.spacing = 15

        return v
    }()

    private func configureView() {
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.elementBackground

        addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 15, left: 15, bottom: 15, right: 15))

        if UIDevice.current.userInterfaceIdiom == .pad {
            stackView.width(200)
        }
    }

    func configureView(with model: SpeakerModel) {
        self.speaker = model
        titleLabel.text = "\(model.firstname) \(model.lastname)"
        subtitleLabel.text = "@\(model.twitter ?? model.github ?? "")"

        if subtitleLabel.text == "@" {
            subtitleLabel.text = ""
        }

        twitterButton.isHidden = model.twitter != nil ? false : true
        githubButton.isHidden = model.github != nil ? false : true

        aboutLabel.text = model.about ?? ""
        aboutLabel.invalidateIntrinsicContentSize()
        guard let imageUrl = URL(string: model.image) else { return }

        self.imageDownloadOperation?.cancel()
        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 100) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }

            self?.profilePicture.image = thumb
        }
    }

    @objc func showMoreByUser() {
//        let searchTerm = titleLabel.text
//
//        if !searchTerm.isEmpty {
//            var tag = TagModel(title: searchTerm, isActive: true)
//            TagSyncService.shared.handleTag(&tag)
//        }
    }

    @objc func openTwitter() {
        guard let twitterHandle = self.speaker?.twitter else { return }

        LoggingHelper.register(event: .openSpeakerTwitter, info: ["speakerId": String(self.speaker!.id)])

        let twitterUrl = "https://twitter.com/\(twitterHandle)"
        if let url = URL(string: twitterUrl) {
           // NSWorkspace.shared.open(url)
        }
    }

    @objc func openGithub() {
        guard let githubHandle = self.speaker?.github else { return }

        LoggingHelper.register(event: .openSpeakerGithub, info: ["speakerId": String(self.speaker!.id)])

        let githubUrl = "https://github.com/\(githubHandle)"
        if let url = URL(string: githubUrl) {
            //NSWorkspace.shared.open(url)
        }
    }


}
