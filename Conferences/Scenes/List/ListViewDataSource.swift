//
//  ConferencesDataSource.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 06/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol ListViewDataSourceDelegate: class {
    func reload()
}

class ListViewDataSource: NSObject {
    
    weak var delegate: ListViewDataSourceDelegate?
    
    var backupConferences: [ConferenceModel] = []

    var conferences: [ConferenceModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.reload()
            }
        }
    }
    
    func filterByWatchlist() {
        conferences = backupConferences.map {
            var c = $0
            c.talks = $0.talks.filter { $0.onWatchlist }
            
            return c
        }
        .filter { !($0.talks.isEmpty) }
    }
    
    func filterByContinueWatching() {
        conferences = backupConferences.map {
            var c = $0
            c.talks = $0.talks.filter { !$0.watched && ($0.progress?.relativePosition ?? 0) > 0 }
            
            return c
        }
        .filter { !($0.talks.isEmpty) }
    }
    
    func restoreBackup() {
        conferences = backupConferences
    }
}

