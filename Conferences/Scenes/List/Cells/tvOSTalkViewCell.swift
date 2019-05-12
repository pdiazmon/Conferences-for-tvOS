//
//  tvOSTalkViewCellCollectionViewCell.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 10/05/2019.
//  Copyright © 2019 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit

class tvOSTalkViewCell: UICollectionViewCell {
    
    private weak var imageDownloadOperation: Operation?
    
    public static let THUMB_WIDTH: CGFloat  = 267.0
    public static let THUMB_HEIGHT: CGFloat = 150.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
    
    lazy var thumbnailImageView: UIImageView = {
        let v = UIImageView()
        
        v.contentMode = .scaleAspectFit
//        v.contentMode = .top
//        v.width(85)
        
//        v.layer.borderColor  = UIColor.white.cgColor
//        v.layer.borderWidth  = 3
        
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .medium)
        l.textColor = .primaryText
        l.lineBreakMode = .byTruncatingTail
        l.numberOfLines = 1
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return l
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
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
        
        v.axis         = .vertical
        v.alignment    = .center
        v.distribution = .fillProportionally
        v.spacing      = 0
        
        return v
    }()
    
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
    
    lazy var progressBar: UIView = {
        let bar = UIView()
        
        bar.backgroundColor = UIColor.orange
        
        bar.layer.cornerRadius = 5
        bar.height(7.5)
        
        return bar
        
    }()
    
    lazy var imageContainer: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.thumbnailImageView, self.progressBar])
        
        v.backgroundColor = UIColor.red
        
        v.axis         = .vertical
        v.alignment    = .center
        v.distribution = .fillProportionally
        v.spacing      = 0

        // TODO: ProgressBar width should be proportional to the view status
        self.progressBar.widthToSuperview()
        self.thumbnailImageView.widthToSuperview()
        
        return v
    }()
    
    func describe() {
        print(progressBar.frame.size)
    }
    
    private func configureView() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(progressBar)
        contentView.addSubview(textStackView)

        thumbnailImageView.top(to: self.contentView, offset: 20)
        thumbnailImageView.centerX(to: self.contentView)

        progressBar.bottom(to: self.thumbnailImageView)
        progressBar.centerX(to: self.thumbnailImageView)
        progressBar.width(to: self.thumbnailImageView)
        
        textStackView.leading(to: self.contentView, offset: 10)
        textStackView.trailing(to: self.contentView, offset: -10)
        textStackView.bottomToSuperview()
    }
    
    func configureView(with model: TalkModel) {
        titleLabel.text = model.title

        subtitleLabel.text = "\(model.speaker.firstname) \(model.speaker.lastname)"
//        contextLabel.text = model.tags.filter { !$0.contains("2019") && !$0.contains("2018") && !$0.contains("2017") && !$0.contains("2016")}.joined(separator: " • ")

        colorContainer.backgroundColor = UIColor().hexStringToUIColor(hex: model.highlightColor)
//
//        //        progressView.isHidden = true
        watchtedIndicator.isHidden = true
//        nowPlayingImage.isHidden = true
//
        if let progress = model.progress {
            if model.currentlyPlaying {
                nowPlayingImage.isHidden = false
            }

            if progress.relativePosition == 1 && progress.watched {
                watchtedIndicator.isHidden = false
            } else if progress.relativePosition > 0 {
//                //                progressView.isHidden = false
//                //                progressView.hasValidProgress = true
//                //                progressView.progress = progress.relativePosition
            }
        }


        guard let imageUrl = URL(string: model.previewImage) else { return }
        self.imageDownloadOperation?.cancel()

        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: tvOSTalkViewCell.THUMB_HEIGHT) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }

            self?.thumbnailImageView.image = thumb
        }
    }
    
}
