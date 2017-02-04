//
//  PortraitViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 04/02/17.
//

import UIKit

class PortraitViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var shouldAutorotate: Bool { return false }
}
