//
//  LightStatusBarViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 05/12/16.
//

import UIKit

class LightStatusBarViewController: UIViewController {

    override var shouldAutorotate: Bool { return false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
