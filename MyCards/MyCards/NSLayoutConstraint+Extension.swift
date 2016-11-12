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

    class func fillInSuperview(_ view: UIView) -> [NSLayoutConstraint] {
        let views = ["view": view]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraints(withVisualFormat:
            "V:|[view]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat:
            "H:|[view]|", options: [], metrics: nil, views: views)
        return constraints
    }
}
