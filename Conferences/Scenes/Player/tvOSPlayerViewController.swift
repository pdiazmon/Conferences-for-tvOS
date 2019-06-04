//
//  tvOSPlayerViewController.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 24/05/2019.
//  Copyright © 2019 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit
import AVKit

class tvOSPlayerViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {

    weak var coordinator: ConferencesCoordinator?
    var mode: ConferencesCoordinatorMode?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }


    func playerViewControllerWillBeginDismissalTransition(_ playerViewController: AVPlayerViewController) {
        NotificationCenter.default.post(.init(name: .continueWatchingUpdated, object: true))
    }
}
