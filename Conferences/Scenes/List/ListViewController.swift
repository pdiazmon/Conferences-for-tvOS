//
//  ListViewController.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

//protocol ListViewUpdater {
//    func didFilter(conferences: Int, talks: Int)
//}

class ListViewController: UITableViewController {
    
    weak var splitDelegate: SplitViewDelegate?
    var detailViewController: DetailViewController? = nil
    var apiClient = APIClient()
    let searchController = UISearchController(searchResultsController: nil)
//    let tagListView = TagListView()
    let dataSource = ListViewDataSource()
    private let talkService = TalkService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.delegate = self
//        tagListView.suggestionsDelegate = self

        configureTableView()
        configureSearchBar()
        talkService.delegate = self
        talkService.fetchData()
        listenForRefreshActiveCell()
    }
    
    private func listenForRefreshActiveCell() {
        NotificationCenter.default.addObserver(forName: .refreshActiveCell, object: nil, queue: nil) { [weak self] (notification) in
            self?.tableView.reloadData()
        }

//        NotificationCenter.default.addObserver(self, selector: #selector(updateSuggestionTables), name: .refreshTableView, object: nil)

    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    private func configureTableView() {
//        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.panelBackground
        tableView.sectionHeaderHeight = 100
        tableView.rowHeight = 70
        tableView.register(TalkViewCell.self, forCellReuseIdentifier: "TalkViewCell")
    }
    
    func configureSearchBar() {
//        searchController.searchBar.delegate = self
//        searchController.searchBar.barStyle = .blackTranslucent
//        searchController.searchBar.autocapitalizationType = .none
//
//        searchController.searchBar.inputAccessoryView = tagListView
//
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//
//        navigationItem.searchController = searchController
//        self.definesPresentationContext = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let talk = dataSource.conferences[indexPath.section].talks[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.configureView(with: talk)
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    func activateSearch() {
        searchController.searchBar.becomeFirstResponder()
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.conferences.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.conferences[section].talks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TalkViewCell", for: indexPath) as? TalkViewCell else {
            return UITableViewCell()
        }
        
        let talk = dataSource.conferences[indexPath.section].talks[indexPath.row]
        cell.configureView(with: talk)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.elementBackground
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = UIColor.elementBackground
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let conferenceView = ConferenceHeaderView(safeAreaInsets: tableView.safeAreaInsets)
        let conference = dataSource.conferences[section]
        
        conferenceView.configureView(with: conference)
        
        return conferenceView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let talk = dataSource.conferences[indexPath.section].talks[indexPath.row]
        splitDelegate?.didSelectTalk(talk: talk)
    }
}

//extension ListViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        talkService.filterTalks(by: searchController.searchBar.text ?? "")
//
//        updateSuggestionTables()
//
//    }
//
//    @objc func updateSuggestionTables() {
//        // To avoid performance issues, only get suggestions when the searchbar text has a minimun length of 2 characters
//        if (searchController.searchBar.text?.count ?? 0 > 1) {
//            var prevSelectedSuggestion: Suggestion?
//
//            if (tagListView.areSuggestionSourcesShown()) {
//                prevSelectedSuggestion = tagListView.selectedSuggestion
//            }
//
//            tagListView.updateSuggestions(to: talkService.getSuggestions(basedOn: searchController.searchBar.text))
//
//            tagListView.selectedSuggestion = tagListView.suggestions.filter { $0.completeWord == prevSelectedSuggestion?.completeWord }.first
//
//            tagListView.reloadTables()
//
//            if ( !tagListView.areSuggestionsShown() && !tagListView.areSuggestionSourcesShown()) {
//                tagListView.showSuggestionsTable()
//            }
//        }
//        else {
//            tagListView.hideSuggestionsTable()
//            tagListView.hideSuggestionSourcesTable()
//        }
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        reload()
//    }
//}

//// MARK: - Search methods
//extension ListViewController {
//
//    func searchBarIsEmpty() -> Bool {
//        return searchController.searchBar.text?.isEmpty ?? true
//    }
//
//    func isFiltering() -> Bool {
//        return searchController.isActive && (!searchBarIsEmpty() || TagSyncService.shared.activeTags().count > 0)
//    }
//}

// MARK: - UISearchBar Delegate
extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

    }
}

extension ListViewController: ListViewDataSourceDelegate {
    func didSelectTalk(_ talk: TalkModel) {
        self.splitDelegate?.didSelectTalk(talk: talk)
    }
    
    func reload() {
        tableView.reloadData()
    }
}

extension ListViewController: TalkServiceDelegate {
    func didFetch(_ conferences: [Codable]) {
        dataSource.conferences = conferences as? [ConferenceModel] ?? []
    }

    func fetchFailed(with error: APIError) {
        dataSource.conferences = []
    }

    func getSearchText() -> String {
        return searchController.searchBar.text ?? ""
    }
}

//extension ListViewController: SuggestionDelegate {
//    func didSelectSuggestion(_ suggestion: Suggestion) {
//        searchController.searchBar.text = suggestion.completeWord
//
//        if (suggestion.sources.count > 1) {
//            tagListView.updateSuggestionSources(to: suggestion)
//            tagListView.showSuggestionSourcesTable()
//        }
//    }
//
//    func didSelectSuggestionSource(suggestionSource: SuggestionSource, completeWord: String) {
//        searchController.searchBar.text = suggestionSource.source.getSearchText() + SuggestionSourceEnum.sourceCriteriaLimit + completeWord
//        tagListView.hideSuggestionSourcesTable()
//    }
//
//}
