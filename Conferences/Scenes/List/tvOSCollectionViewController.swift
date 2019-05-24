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

class tvOSCollectionViewController: UICollectionViewController {

    var apiClient           = APIClient()
    let dataSource          = ListViewDataSource()
    private let talkService = TalkService()
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.delegate = self
        
        talkService.delegate = self
        talkService.fetchData()
        listenForRefreshActiveCell()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView?.register(tvOSTalkViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(ConferenceHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)

        self.view.backgroundColor = .elementBackground
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
    }
    
    private func listenForRefreshActiveCell() {
        NotificationCenter.default.addObserver(forName: .refreshActiveCell, object: nil, queue: nil) { [weak self] (notification) in
            self?.collectionView.reloadData()
        }
    }
    
    func reloadTableView() {
        self.collectionView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.conferences.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.conferences[section].talks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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

    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let talk = dataSource.conferences[indexPath.section].talks[indexPath.row]
        coordinator?.showTalkDetails(talk: talk)
    }
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension tvOSCollectionViewController: ListViewDataSourceDelegate {
    func didSelectTalk(_ talk: TalkModel) {
//        self.splitDelegate?.didSelectTalk(talk: talk)
//        print(talk.title)
    }
    
    func reload() {
        self.collectionView.reloadData()
    }
}

extension tvOSCollectionViewController: TalkServiceDelegate {
    func didFetch(_ conferences: [Codable]) {
        dataSource.conferences = conferences as? [ConferenceModel] ?? []
    }
    
    func fetchFailed(with error: APIError) {
        dataSource.conferences = []
    }
    
    func getSearchText() -> String {
//        return searchController.searchBar.text ?? ""
        return ""
    }
}
