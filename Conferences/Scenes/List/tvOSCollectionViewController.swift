//
//  tvOSCollectionViewController.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 10/05/2019.
//  Copyright © 2019 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit
import ParallaxView

private let reuseIdentifier       = "Cell"
private let headerReuseIdentifier = "Header"

class tvOSCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var apiClient           = APIClient()
    let dataSource          = ListViewDataSource()
    private let talkService = TalkService()
    weak var coordinator: ConferencesCoordinator?
    private var collectionView: UICollectionView!
    private var mode: ConferencesCoordinatorMode
    
    init(collectionViewLayout: UICollectionViewFlowLayout, mode: ConferencesCoordinatorMode) {
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.mode           = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(collectionView)
        
        self.collectionView.delegate   = self
        self.collectionView.dataSource = self
        
        dataSource.delegate = self
        
        talkService.delegate = self
        
        talkService.fetchData()
        observers()

        // Register cell classes
        self.collectionView?.register(tvOSTalkViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(ConferenceHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)

        self.view.backgroundColor = .elementBackground
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        
        self.collectionView.edgesToSuperview()
    }
    
    private func observers() {
        NotificationCenter.default.addObserver(forName: .continueWatchingUpdated, object: nil, queue: nil) { [weak self] (notification) in
            if (self?.mode == .continueWatching) {
                self?.dataSource.filterByContinueWatching()
            }
            else {
                self?.reloadTableView()
            }
        }
        
        if (mode == .watchList) {
            NotificationCenter.default.addObserver(forName: .watchlistUpdated, object: nil, queue: nil) { [weak self] (notification) in
                self?.dataSource.filterByWatchlist()
            }
        }
    }
    
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.conferences.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.conferences[section].talks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? tvOSTalkViewCell else {
            return UICollectionViewCell()
        }
        
        let talk = dataSource.conferences[indexPath.section].talks[indexPath.row]
        cell.configureView(with: talk)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.elementBackground
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor        = UIColor.elementBackground
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            if let conferenceView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as? ConferenceHeaderView {
                
                conferenceView.configureView(with: dataSource.conferences[indexPath.section])
                
                return conferenceView
            }
            
            return UICollectionReusableView()
        
        default:
            assert(false, "Unexpected element kind")
        }
    }
    

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let prev = context.previouslyFocusedItem as? tvOSTalkViewCell {
            prev.setFocusOff()
        }

        if let next = context.nextFocusedItem as? tvOSTalkViewCell {
            next.setFocusOn()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let talk = dataSource.conferences[indexPath.section].talks[indexPath.row]
        coordinator?.showTalkDetails(talk: talk)
    } 
}

extension tvOSCollectionViewController: ListViewDataSourceDelegate {
    
    func reload() {
        reloadTableView()
    }
}

extension tvOSCollectionViewController: TalkServiceDelegate {
    func didFetch(_ conferences: [Codable]) {
        dataSource.backupConferences = conferences as? [ConferenceModel] ?? []
        
        switch mode {
        case .allConferences:
            dataSource.restoreBackup()
        case .watchList:
            dataSource.filterByWatchlist()
        case .continueWatching:
            dataSource.filterByContinueWatching()
        }
    }
    
    func fetchFailed(with error: APIError) {
        dataSource.conferences = []
    }
    
    func getSearchText() -> String {
        return ""
    }
}
