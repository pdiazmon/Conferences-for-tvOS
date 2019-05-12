//
//  TalkViewCell.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import TinyConstraints

class TalkViewCell: UITableViewCell {
    private weak var imageDownloadOperation: Operation?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var colorContainer: UIView = {
        let v = UIView()
        v.width(0.7)

        return v
    }()

    private lazy var nowPlayingImage: UIImageView = {
        let v = UIImageView()

        //v.image = NSImage(named: "speaker")
        v.isHidden = true

        v.height(15)
        v.width(15)

        return v
    }()

    private lazy var thumbnailImageView: UIImageView = {
        let v = UIImageView()

        v.contentMode = .scaleAspectFit
        v.width(85)

        return v
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = .primaryText
        l.lineBreakMode = .byTruncatingTail
        l.numberOfLines = 2
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return l
    }()

    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    private lazy var contextLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .tertiaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    private lazy var textStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel, self.contextLabel])

        v.axis = .vertical
        v.alignment = .leading
        v.distribution = .fill
        v.spacing = 0

        return v
    }()

//    private lazy var progressView: UIView = {
//        let v = UIView()
//
//        v.backgroundColor = .lightGray
//        v.width(4)
//
//        return v
//    }()

    private lazy var watchtedIndicator: UIImageView = {
        let v = UIImageView()

        v.image = UIImage(named: "watched-tick")
        v.width(10)
        v.height(10)

        return v
    }()

    private lazy var progressStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.watchtedIndicator])
        
        v.alignment = .center
        self.watchtedIndicator.centerY(to: v)

        return v
    }()

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.textStackView, self.progressStackView])

        v.spacing = 5
        self.watchtedIndicator.trailing(to: v)

        return v
    }()

    private func configureView() {
        contentView.backgroundColor = UIColor.panelBackground
        contentView.addSubview(colorContainer)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(stackView)

        colorContainer.leading(to: self, offset: 15)
        colorContainer.topToSuperview()
        colorContainer.bottomToSuperview()

        thumbnailImageView.top(to: self, offset: 6)
        thumbnailImageView.bottom(to: self, offset: -6)
        thumbnailImageView.leadingToTrailing(of: colorContainer, offset: 20)

        progressStackView.top(to: stackView)
        progressStackView.bottom(to: stackView)

        stackView.top(to: thumbnailImageView)
        stackView.bottom(to: thumbnailImageView)
        stackView.leadingToTrailing(of: thumbnailImageView, offset: 6)
        stackView.trailing(to: self, offset: -20)
    }

    func configureView(with model: TalkModel) {
        titleLabel.text = model.title

        subtitleLabel.text = "\(model.speaker.firstname) \(model.speaker.lastname)"
        contextLabel.text = model.tags.filter { !$0.contains("2019") && !$0.contains("2018") && !$0.contains("2017") && !$0.contains("2016")}.joined(separator: " • ")

        colorContainer.backgroundColor = UIColor().hexStringToUIColor(hex: model.highlightColor)

//        progressView.isHidden = true
        watchtedIndicator.isHidden = true
        nowPlayingImage.isHidden = true

        if let progress = model.progress {
            if model.currentlyPlaying {
                nowPlayingImage.isHidden = false
            }

            if progress.relativePosition == 1 && progress.watched {
                watchtedIndicator.isHidden = false
            } else if progress.relativePosition > 0 {
//                progressView.isHidden = false
//                progressView.hasValidProgress = true
//                progressView.progress = progress.relativePosition
            }
        }


        guard let imageUrl = URL(string: model.previewImage) else { return }
        self.imageDownloadOperation?.cancel()
//        self.thumbnailImageView.image = NSImage(named: "placeholder")

        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 150) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }

            self?.thumbnailImageView.image = thumb
        }
    }
}
