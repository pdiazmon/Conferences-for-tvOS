//
//  ProgressModel.swift
//  Conferences
//
//  Created by Timon Blask on 08/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import RealmSwift

class ProgressModel: Object {
    @objc dynamic var id = 0
    @objc dynamic var watched = false
    @objc dynamic var currentPosition = 0.0
    @objc dynamic var relativePosition = 0.0

    override static func primaryKey() -> String? {
        return "id"
    }
    
    func currentPositionToHoursMinutesSeconds () -> String {
        let hours = Int(currentPosition) / 3600
        let minutes = Int(currentPosition) / 60 % 60
        let seconds = Int(currentPosition) % 60
        return (hours > 0 ? String(format:"%02i:", hours) : "") + String(format:"%02i:%02i", minutes, seconds)
    }
}
