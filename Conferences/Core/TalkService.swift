//
//  TalkService.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

protocol TalkServiceDelegate: class {
    func didFetch(_ conferences: [Codable])
    func fetchFailed(with error: APIError)
    func getSearchText() -> String
}

final class TalkService {
    weak var delegate: TalkServiceDelegate?
    private let apiClient = APIClient()

    private var conferences = [Codable]()
    private var backup = [Codable]()

    init() {
        observe()
    }

    func observe() {
        NotificationCenter.default.addObserver(self, selector: #selector(filterTalks as () -> Void), name: .refreshTableView, object: nil)
    }

    func fetchData() {
        apiClient.send(resource: ConferenceResource.all, completionHandler: { [weak self] (response: Result<[ConferenceModel], APIError>) in
            switch response {
            case .success(let conferences):
                self?.conferences = conferences
                self?.backup      = conferences
                
                DispatchQueue.main.async {
                    self?.delegate?.didFetch(conferences)
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self?.delegate?.fetchFailed(with: error)
                }
            }
        })
    }

    func filterTalks(by searchString: String) {
        guard let seachableBackup = self.backup as? [Searchable] else { return }
        let activeTags = TagSyncService.shared.activeTags()
        
        var currentBatch = seachableBackup
        
        for i in 0..<currentBatch.count {
            var conf = currentBatch[i] as? ConferenceModel
            if (conf != nil) {
                if (searchString.count > 0) {
                    conf!.talks = conf!.talks.filter { $0.matches(searchCriteria: searchString) && $0.matchesAll(activeTags: activeTags) }
                }
                else {
                    conf!.talks = conf!.talks.filter { $0.matchesAll(activeTags: activeTags) }
                }
                currentBatch[i] = conf!
            }
        }
        
        currentBatch = currentBatch.filter { ($0 as? ConferenceModel)?.talks.count ?? 0 > 0 }
        
        self.conferences = currentBatch as! [Codable]
        
        DispatchQueue.main.async {
            self.delegate?.didFetch(self.conferences)
        }
    }

    @objc private func filterTalks() {
        filterTalks(by: delegate?.getSearchText() ?? "")
    }
    
    func getSuggestions(basedOn: String?) -> [Suggestion] {
        guard let conferencesBackup = self.backup as? [ConferenceModel] else { return [] }
        guard let based = basedOn else { return [] }

        var ret: [Suggestion] = []
        let activeTags = TagSyncService.shared.activeTags()
        
        for conference in conferencesBackup {
            for talk in conference.talks {
                
                if (talk.speaker.firstname.lowercased().contains(based.lowercased()) && talk.matchesAll(activeTags: activeTags)) {
                    if let existingSuggestion = ret.filter ({ $0.completeWord == talk.speaker.firstname.lowercased() }).first {
                        existingSuggestion.add(source: .speakerFirstname, for: talk)
                        existingSuggestion.add(talk: talk)
                    }
                    else {
                        let newSuggestion = Suggestion(text: based, completeWord: talk.speaker.firstname.lowercased())
                        newSuggestion.add(source: .speakerFirstname, for: talk)
                        newSuggestion.add(talk: talk)
                        ret.append(newSuggestion)
                    }
                }
                
                if (talk.speaker.lastname.lowercased().contains(based.lowercased()) && talk.matchesAll(activeTags: activeTags)) {
                    if let existingSuggestion = ret.filter ({ $0.completeWord == talk.speaker.lastname.lowercased() }).first {
                        existingSuggestion.add(source: .speakerLastname, for: talk)
                        existingSuggestion.add(talk: talk)
                    }
                    else {
                        let newSuggestion = Suggestion(text: based, completeWord: talk.speaker.lastname.lowercased())
                        newSuggestion.add(source: .speakerLastname, for: talk)
                        newSuggestion.add(talk: talk)
                        ret.append(newSuggestion)
                    }
                }
                
                if ((talk.speaker.twitter?.lowercased().contains(based.lowercased()) ?? false) && talk.matchesAll(activeTags: activeTags)) {
                    if let existingSuggestion = ret.filter ({ $0.completeWord == talk.speaker.twitter?.lowercased() }).first {
                        existingSuggestion.add(source: .twitter, for: talk)
                        existingSuggestion.add(talk: talk)
                    }
                    else {
                        let newSuggestion = Suggestion(text: based, completeWord: talk.speaker.twitter?.lowercased() ?? "")
                        newSuggestion.add(source: .twitter, for: talk)
                        newSuggestion.add(talk: talk)
                        ret.append(newSuggestion)
                    }
                }
                
                let pattern = "[^A-Za-z0-9\\-]+"
                
                var result = talk.title.replacingOccurrences(of: pattern, with: " ", options: [.regularExpression])
                for word in result.components(separatedBy: " ") {
                    if (word.lowercased().contains(based.lowercased()) && talk.matchesAll(activeTags: activeTags)) {
                        if let existingSuggestion = ret.filter ({ $0.completeWord == word.lowercased() }).first {
                            existingSuggestion.add(source: .title, for: talk)
                            existingSuggestion.add(talk: talk)
                        }
                        else {
                            let newSuggestion = Suggestion(text: based, completeWord: word.lowercased())
                            newSuggestion.add(source: .title, for: talk)
                            newSuggestion.add(talk: talk)
                            ret.append(newSuggestion)
                        }
                    }
                }
                
                result = talk.details?.replacingOccurrences(of: pattern, with: " ", options: [.regularExpression]) ?? ""
                for word in result.components(separatedBy: " ") {
                    if (word.lowercased().contains(based.lowercased()) && talk.matchesAll(activeTags: activeTags)) {
                        if let existingSuggestion = ret.filter({ $0.completeWord == word.lowercased() }).first {
                            existingSuggestion.add(source: .details, for: talk)
                            existingSuggestion.add(talk: talk)
                        }
                        else {
                            let newSuggestion = Suggestion(text: based, completeWord: word.lowercased())
                            newSuggestion.add(source: .details, for: talk)
                            newSuggestion.add(talk: talk)
                            ret.append(newSuggestion)
                        }
                    }
                }
            }
        }
        
        return ret.sorted { $0.inTalks.count > $1.inTalks.count }
    }
}
