//
//  ActionView.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import TinyConstraints

class ActionView: UIView {

    private var talk: TalkModel?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var watchlistButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.tintColor = .white
        b.setImage(UIImage(named: "watchlist"), for: .normal)
        b.addTarget(self, action: #selector(toggleWatchlist), for: .touchUpInside)

        return b
    }()

    private lazy var watchButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.tintColor = .white
        b.setImage(UIImage(named: "watch"), for: .normal)
        b.addTarget(self, action: #selector(toggleWatch), for: .touchUpInside)

        return b
    }()

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.watchlistButton, self.watchButton])

        v.spacing = 20

        return v
    }()

    private func configureView() {
        addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 15, left: 15, bottom: 15, right: 15))
    }

    func configureView(with talk: TalkModel) {
        self.talk = talk

        let watchlistImage = talk.onWatchlist ? UIImage(named: "watchlist_filled") : UIImage(named: "watchlist")
        let watchImage = talk.watched ? UIImage(named: "watch_filled") : UIImage(named: "watch")

        watchlistButton.setImage(watchlistImage, for: .normal)
        watchButton.setImage(watchImage, for: .normal)
    }

    @objc func toggleWatch() {
        guard var talk = self.talk else { return }

        talk.watched.toggle()
        
        let watchImage = talk.watched ? UIImage(named: "watch_filled") : UIImage(named: "watch")
        watchButton.setImage(watchImage, for: .normal)
        
        NotificationCenter.default.post(Notification(name: .refreshActiveCell))

        var tag = TagModel(title: "Confinue watching", query: "realm_continue", isActive: false)
        TagSyncService.shared.handleStoredTag(&tag)
    }

    @objc func toggleWatchlist() {
        guard var talk = self.talk else { return }

        talk.onWatchlist.toggle()

        let watchlistImage = talk.onWatchlist ? UIImage(named: "watchlist_filled") : UIImage(named: "watchlist")
        watchlistButton.setImage(watchlistImage, for: .normal)
        
        NotificationCenter.default.post(Notification(name: .refreshActiveCell))
        

        var tag = TagModel(title: "Watchlist", query: "realm_watchlist", isActive: talk.onWatchlist)
        TagSyncService.shared.handleStoredTag(&tag)
    }

}
