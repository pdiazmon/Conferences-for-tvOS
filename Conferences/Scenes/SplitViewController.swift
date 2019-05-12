//
//  SplitViewController.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol SplitViewDelegate: class {
    func didSelectTalk(talk: TalkModel)
}

final class SplitViewController: UISplitViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        configureView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            listViewController.reloadTableView()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var listViewController: ListViewController = {
        let listViewController = ListViewController()
        listViewController.title = "Conferences"
        listViewController.splitDelegate = self
        return listViewController
    }()

    private lazy var listViewControllerNavigation: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: listViewController)
        navigationController.navigationBar.barTintColor = UIColor.elementBackground
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.isTranslucent = false
//        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        navigationController.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        return navigationController
    }()

    private lazy var detailViewController: DetailViewController = {
        let detailViewController = DetailViewController()

        return detailViewController
    }()

    private func configureView() {
        self.delegate = self
        self.tabBarItem.title = "Conferences"
        self.minimumPrimaryColumnWidth = 380
        self.maximumPrimaryColumnWidth = 400
        self.view.backgroundColor = .elementBackground
        self.preferredDisplayMode = .allVisible
        self.viewControllers = [listViewControllerNavigation, detailViewController]
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension SplitViewController: SplitViewDelegate {
    func didSelectTalk(talk: TalkModel) {
        detailViewController.configureView(with: talk)
        detailViewController.navigationItem.leftBarButtonItem = self.displayModeButtonItem
//        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.scrollToTop()

        showDetailViewController(detailViewController, sender: nil)
    }
}
