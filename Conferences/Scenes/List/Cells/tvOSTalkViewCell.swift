//
//  tvOSTalkViewCellCollectionViewCell.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 10/05/2019.
//  Copyright © 2019 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit
import ParallaxView

class tvOSTalkViewCell: UICollectionViewCell {

    private weak var imageDownloadOperation: Operation?
    
    public static let THUMB_WIDTH: CGFloat  = 305.0
    public static let THUMB_HEIGHT: CGFloat = 255.0
    
    private var pbWidthConstraint: NSLayoutConstraint?
    
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
    
    lazy var thumbnailImageView: UIImageView = {
        let v = UIImageView()
        
        v.contentMode = .scaleAspectFit
        
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28, weight: .medium)
        l.textColor = .primaryText
        l.lineBreakMode = .byTruncatingTail
        l.numberOfLines = 1
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return l
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 25)
        l.textColor = .secondaryText
        l.lineBreakMode = .byTruncatingTail
        
        return l
    }()
    
    private lazy var textStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])

        v.axis         = .vertical
        v.alignment    = .center
        v.distribution = .fillProportionally
        v.spacing      = 0

        return v
    }()
    
    lazy var progressBar: UIView = {
        let bar = UIView()
        
        bar.backgroundColor = UIColor.orange
        
        bar.layer.cornerRadius = 5
        bar.height(8.5)
        
        return bar
        
    }()
    
    lazy var imageContainer: ParallaxView = {
        var imgc = ParallaxView()
        
        imgc.addSubview(self.thumbnailImageView)
        imgc.addSubview(self.progressBar)
        
        self.thumbnailImageView.edgesToSuperview()

        self.progressBar.leading(to: self.thumbnailImageView)
        self.progressBar.bottom(to: self.thumbnailImageView)
        
        imgc.parallaxEffectOptions.glowAlpha = 0.4
        imgc.parallaxEffectOptions.shadowPanDeviation = 10
        imgc.parallaxEffectOptions.parallaxMotionEffect.viewingAngleX = CGFloat(Double.pi/4/30)
        imgc.parallaxEffectOptions.parallaxMotionEffect.viewingAngleY = CGFloat(Double.pi/4/30)
        imgc.parallaxEffectOptions.parallaxMotionEffect.panValue = CGFloat(30)
        
        return imgc
    }()
    
    func describe() {
        print(progressBar.frame.size)
    }
    
    private func configureView() {
        contentView.addSubview(imageContainer)
        contentView.addSubview(textStackView)

        imageContainer.top(to: self.contentView, offset: 20)
        imageContainer.centerX(to: self.contentView)
        imageContainer.widthToSuperview()
        
        textStackView.leading(to: self.contentView, offset: 10)
        textStackView.trailing(to: self.contentView, offset: -10)
        textStackView.bottomToSuperview()
        
    }
    
    func configureView(with model: TalkModel) {
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = model.title

            self?.subtitleLabel.text = "\(model.speaker.firstname) \(model.speaker.lastname)"
//        contextLabel.text = model.tags.filter { !$0.contains("2019") && !$0.contains("2018") && !$0.contains("2017") && !$0.contains("2016")}.joined(separator: " • ")

            self?.colorContainer.backgroundColor = UIColor().hexStringToUIColor(hex: model.highlightColor)
        
            self?.setProgressBarPosition(model)
        }
        
        guard let imageUrl = URL(string: model.previewImage) else { return }
        self.imageDownloadOperation?.cancel()

        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: tvOSTalkViewCell.THUMB_HEIGHT) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }

            DispatchQueue.main.async { [weak self] in
                self?.thumbnailImageView.image = thumb
                self?.thumbnailImageView.height(tvOSTalkViewCell.THUMB_HEIGHT)
            }
        }
    }
    
    private func setProgressBarPosition(_ talk: TalkModel) {
        let playbackPosition = CGFloat(talk.progress?.relativePosition ?? 0)

        if let constraint = self.pbWidthConstraint {
            constraint.isActive = false
            progressBar.removeConstraint(constraint)
        }
        
        self.pbWidthConstraint = progressBar.widthToSuperview(multiplier: playbackPosition)
    }
    
    func setFocusOn() {
        DispatchQueue.main.async { [weak self] in
            self?.imageContainer.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self?.imageContainer.addParallaxMotionEffects()
        }
    }
    
    func setFocusOff() {
        DispatchQueue.main.async { [weak self] in
            self?.imageContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
            self?.imageContainer.removeParallaxMotionEffects()
        }
    }
    
    
    
}
