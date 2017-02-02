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

    class func filledInSuperview(_ view: UIView, padding: CGFloat? = nil) -> [NSLayoutConstraint] {
        let views = ["view": view]
        var metrics: [String: Any] = ["pad": 0]
        padding.map { metrics["pad"] = $0 }
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-(==pad)-[view]-(==pad)-|", options: [], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat:
            "H:|-(==pad)-[view]-(==pad)-|", options: [], metrics: metrics, views: views)
        return constraints
    }
}
