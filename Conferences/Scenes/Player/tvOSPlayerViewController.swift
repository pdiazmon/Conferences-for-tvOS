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

    var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
    }


    func playerViewControllerWillBeginDismissalTransition(_ playerViewController: AVPlayerViewController) {
        coordinator?.reloadCollection()
    }
}
