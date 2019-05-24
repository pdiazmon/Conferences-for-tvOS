//
//  ConferenceHeaderView.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class ConferenceHeaderView: UICollectionReusableView {

    private weak var imageDownloadOperation: Operation?
    private var leftSafeAreaInset: CGFloat = 0
    
    private let LOGO_HEIGHTWIDTH: CGFloat = 160
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    init(safeAreaInsets: UIEdgeInsets) {
        leftSafeAreaInset = safeAreaInsets.left
        
        super.init(frame: .zero)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var logo: UIImageView = {
        let v = UIImageView(image: nil)
        v.layer.borderColor  = UIColor.activeColor.cgColor
        v.layer.borderWidth  = 3
        v.layer.cornerRadius = LOGO_HEIGHTWIDTH / 2
        v.clipsToBounds = true

        v.height(LOGO_HEIGHTWIDTH)
        v.width(LOGO_HEIGHTWIDTH)

        return v
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 35, weight: .semibold)
        l.textColor = .primaryText
        l.lineBreakMode = .byTruncatingTail
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return l
    }()

    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 30)
        l.textColor = .secondaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()
    
    private lazy var aboutLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 23, weight: .semibold)
        l.textColor = .secondaryText
        
        l.lineBreakMode = .byWordWrapping
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        l.textAlignment = .left
        l.allowsDefaultTighteningForTruncation = true
        l.numberOfLines = 5

        return l
    }()
    
    private lazy var whiteLine: UIView = {
        let spacing = UIView()
        spacing.backgroundColor = UIColor.activeColor
        spacing.height(1)
        
        return spacing
    }()

    private lazy var textStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel, self.whiteLine, self.aboutLabel])
        
        self.whiteLine.widthToSuperview()

        v.axis         = .vertical
        v.spacing      = 5
        v.alignment    = .leading
        v.distribution = .fill

        return v
    }()

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.logo, self.textStackView])

        v.alignment = .center
        v.distribution = .fill
        v.spacing = 15

        return v
    }()

    private func configureView() {
        let containerView = UIView()
        backgroundColor = UIColor.elementBackground
        containerView.backgroundColor = UIColor.elementBackground
        
        addSubview(containerView)
        
        containerView.edgesToSuperview(insets: .init(top: 30, left: 0, bottom: 20, right: 0))
        containerView.addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 20, left: 10, bottom: 20, right: 10))
    }

    func configureView(with conference: ConferenceModel) {
        titleLabel.text    = conference.name
        subtitleLabel.text = conference.location
        aboutLabel.text    = conference.about

        guard let imageUrl = URL(string: conference.logo) else { return }

        self.imageDownloadOperation?.cancel()
        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 100) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }
            self?.logo.isHidden = false
            self?.logo.image = thumb
        }
    }

}
