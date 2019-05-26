//
//  ConferencesDataSource.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 06/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol ListViewDataSourceDelegate: class {
    func didSelectTalk(_ talk: TalkModel)
    func reload()
}

class ListViewDataSource: NSObject {
    
    weak var delegate: ListViewDataSourceDelegate?

    var conferences: [ConferenceModel] = [] {
        didSet {
            DispatchQueue.main.async {
                if let talk = self.conferences.first?.talks.first,
                    let window = UIApplication.shared.keyWindow,
                    window.traitCollection.horizontalSizeClass == .regular {
                    self.delegate?.didSelectTalk(talk)
                }

                self.delegate?.reload()
            }
        }
    }
}

