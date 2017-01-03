//
//  HiddenStatusBarViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 05/12/16.
//

import UIKit

class HiddenStatusBarViewController: UIViewController {

    //swiftlint:disable variable_name
    fileprivate var statusBarHidden: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var shouldAutorotate: Bool { return false }
    override var prefersStatusBarHidden: Bool { return statusBarHidden }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .fade }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    //swiftlint:enable variable_name

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
            self.statusBarHidden = true
        }
    }
}
