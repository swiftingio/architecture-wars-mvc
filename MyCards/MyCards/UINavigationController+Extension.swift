//
//  UINavigationController+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 05/12/16.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
