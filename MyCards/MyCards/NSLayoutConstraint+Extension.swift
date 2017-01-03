//
//  NSLayoutConstraint+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 11/11/16.
//

import UIKit

extension NSLayoutConstraint {

    class func centeredInSuperview(_ view: UIView) -> [NSLayoutConstraint] {
        return [
            centeredHorizontallyInSuperview(view),
            centeredVerticallyInSuperview(view)
        ]
    }

    class func centeredHorizontallyInSuperview(_ view: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem:
            view.superview!, attribute: .centerX, multiplier: 1, constant: 0)
    }

    class func centeredVerticallyInSuperview(_ view: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem:
            view.superview!, attribute: .centerY, multiplier: 1, constant: 0)
    }

    class func filledInSuperview(_ view: UIView) -> [NSLayoutConstraint] {
        let views = ["view": view]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraints(withVisualFormat:
            "V:|[view]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat:
            "H:|[view]|", options: [], metrics: nil, views: views)
        return constraints
    }
}
