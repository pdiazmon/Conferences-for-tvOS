//
//  Talk.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
//import RealmSwift
import ConferencesCoreTV

struct TalkModel: Codable {
    var id: Int
    var title: String
    var url: String
    var source: VideoSourceModel
    var videoId: String
    var details: String?
    var speaker: SpeakerModel
    var highlightColor: String
    var tags: [String]
}

extension TalkModel {
    var previewImage: String {
        return "\(Environment.url)/preview/previewImage-\(videoId).jpeg"
    }
}

extension TalkModel: Equatable {
    static func == (lhs: TalkModel, rhs: TalkModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension TalkModel: Searchable {
    var searchString: String {
        return #"""
            \#(title)
            \#(details ?? "")
            \#(speaker.firstname)
            \#(speaker.lastname)
            \#(speaker.twitter ?? "")
            \#(tags.joined(separator: " "))
            \#(onWatchlist ? "realm_watchlist" : "")
            \#((progress?.watched == false && progress?.currentPosition != 0.0) ? "realm_continue" : "")
            """#
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}

extension TalkModel {
    var watched: Bool {
        get {
            return progress?.watched ?? false
        }

        set {
            let watched = newValue ? 1.0 : 0.0
            trackProgress(currentPosition: 0, relativePosition: watched)
        }
    }

    var progress: ProgressModel? {
        return Storage.shared.getProgress(for: self.id)
    }

    var onWatchlist: Bool {
        get {
            return Storage.shared.isOnWatchlist(for: self.id)?.active ?? false
        }

        set {
            let model = WatchlistModel()
            model.id = self.id
            model.active = newValue

            Storage.shared.setFavorite(model)
        }
    }

    var currentlyPlaying: Bool {
        get {
            return Storage.shared.currentlyWatching(for: self.id)
        }

        set {
            let model = CurrentlyWatchingModel()
            model.id = self.id

            Storage.shared.currentlyWatching(object: model)
        }
    }
}

extension TalkModel {
    func trackProgress(currentPosition: Double, relativePosition: Double) {
        let model = ProgressModel()
        model.id = self.id
        model.currentPosition = relativePosition >= 0.97 ? 0.0 : currentPosition
        model.relativePosition = relativePosition >= 0.97 ? 1.0 : relativePosition
        model.watched = relativePosition >= 0.97

        Storage.shared.trackProgress(object: model)
    }
    
    func initializeProgress() {
        self.trackProgress(currentPosition: 0, relativePosition: 0)
        
        var tag = TagModel(title: "Continue watching", query: "realm_continue", isActive: true)
        TagSyncService.shared.handleStoredTag(&tag)
    }
}

extension TalkModel {
    func matchesAll(activeTags: [TagModel]) -> Bool {
        for active in activeTags {
            if (active.title == TagSyncService.watchedTitle) {
                if (!self.watched) { return false }
            }
            else if (active.title == TagSyncService.notWatchedTitle) {
                if (self.watched) { return false }
            }
            else if (active.title == TagSyncService.watchlistTitle) {
                if (!self.onWatchlist) { return false }
            }
            else if (active.title == TagSyncService.continueWatchingTitle) {
                if (!self.currentlyPlaying) { return false }
            }
            else if (self.tags.filter { $0.contains(active.title) }.count == 0) { return false }
        }
        return true
    }
    
    func matches(searchCriteria: String) -> Bool {
        guard searchCriteria.count > 0 else { return true }
        
        let components = searchCriteria.components(separatedBy: SuggestionSourceEnum.sourceCriteriaLimit)
        
        // TODO: Seach with multiple "key:text" criterias
        if (components.count == 2 && SuggestionSourceEnum.isSource(text: components.first ?? "")) {
            
            if (components.first == SuggestionSourceEnum.speakerFirstname.rawValue.text) {
                return self.speaker.firstname.lowercased().contains(components.last?.lowercased() ?? "") ||
                       self.speaker.lastname.lowercased().contains(components.last?.lowercased() ?? "")
            }
            else if (components.first == SuggestionSourceEnum.title.rawValue.text) {
                return self.title.lowercased().contains(components.last?.lowercased() ?? "")
            }
            else if (components.first == SuggestionSourceEnum.twitter.rawValue.text) {
                return self.speaker.twitter?.lowercased().contains(components.last?.lowercased() ?? "") ?? false
            }
            else if (components.first == SuggestionSourceEnum.details.rawValue.text) {
                return self.details?.lowercased().contains(components.last?.lowercased() ?? "") ?? false
            }
            else {
                return false
            }
        }
        else {
            return self.searchString.contains(searchCriteria.lowercased())
        }
    }
}

extension MutableCollection {
    mutating func mapInPlace(_ x: (inout Element) -> ()) {
        for i in indices {
            x(&self[i])
        }
    }
}
