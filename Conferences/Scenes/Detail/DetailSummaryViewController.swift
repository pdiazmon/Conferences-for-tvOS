//
//  DetailSummaryViewController.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class DetailSummaryViewController: UIViewController {

        private lazy var titleLabel: UILabel = {
            let l = UILabel()
            l.font = .systemFont(ofSize: 20, weight: .bold)

            l.lineBreakMode = .byTruncatingTail
            l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            l.allowsDefaultTighteningForTruncation = true
            l.numberOfLines = 1
            l.textColor = .primaryText


            return l
        }()

        private lazy var summaryLabel: UILabel = {
            let l = UILabel()
            l.font = .systemFont(ofSize: 14)
            l.textColor = .secondaryText

            l.lineBreakMode = .byWordWrapping
            l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            l.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            l.allowsDefaultTighteningForTruncation = true
            l.numberOfLines = 0

            return l
        }()

        private lazy var contextLabel: UILabel = {
            let l = UILabel()
            l.font = .systemFont(ofSize: 12)
            l.textColor = .tertiaryText
            l.lineBreakMode = .byTruncatingTail
            l.allowsDefaultTighteningForTruncation = true

            return l
        }()

        lazy var speakerView: SpeakerView = SpeakerView()
        lazy var actionView: ActionView = ActionView()

        private lazy var labelStackView: UIStackView = {
            let v = UIStackView(arrangedSubviews: [self.titleLabel, self.summaryLabel, self.contextLabel])

            v.axis = .vertical
            v.alignment = .leading
            v.spacing = 24

            return v
        }()

        private lazy var leftStackView: UIStackView = {
            let v = UIStackView(arrangedSubviews: [self.labelStackView, self.actionView])

            v.axis = .vertical
            v.distribution = .fill
            v.alignment = .leading
            v.spacing = 24

            return v
        }()

        private lazy var stackView: UIStackView = {
            let v = UIStackView(arrangedSubviews: [self.leftStackView, self.speakerView])

            let axis: NSLayoutConstraint.Axis  = UIDevice.current.userInterfaceIdiom == .pad ? .horizontal : .vertical
            v.axis = axis

            v.alignment = .top
            v.distribution = .fill
            v.spacing = 24
            return v
        }()


        override func viewDidLoad() {
            view.backgroundColor = .panelBackground
            view.addSubview(stackView)

            stackView.edgesToSuperview(insets: .init(top: 20, left: 20, bottom: 20, right: 20))
        }

        func configureView(with talk: TalkModel) {
            titleLabel.text = talk.title
            summaryLabel.text = talk.details ?? ""
            contextLabel.text = talk.tags.filter { !$0.contains("2019") && !$0.contains("2018") && !$0.contains("2017") && !$0.contains("2016")}.joined(separator: " • ")

            contextLabel.isHidden = contextLabel.text?.isEmpty ?? true
            speakerView.configureView(with: talk.speaker)
            actionView.configureView(with: talk)
        }

}
