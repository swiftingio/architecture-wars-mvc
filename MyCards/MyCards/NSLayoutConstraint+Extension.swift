//
//  NSLayoutConstraint+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 11/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    class func centerInSuperview(_ view: UIView) -> [NSLayoutConstraint] {
        return [
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem:
                view.superview!, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem:
                view.superview!, attribute: .centerY, multiplier: 1, constant: 0)
        ]
    }
}
