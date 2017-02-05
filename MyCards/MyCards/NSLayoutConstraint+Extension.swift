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
            centeredInSuperview(view, with: .centerX),
            centeredInSuperview(view, with: .centerY)
        ]
    }

    class func centeredInSuperview(_ view: UIView, with attribute: NSLayoutAttribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .equal, toItem:
            view.superview!, attribute: attribute, multiplier: 1, constant: 0)
    }

    class func filledInSuperview(_ view: UIView, padding: CGFloat = 0) -> [NSLayoutConstraint] {
        guard let superview = view.superview else { return  [] }
        view.layoutMargins = .zero
        superview.layoutMargins = .zero
        let layoutMarginsGuide = superview.layoutMarginsGuide
        return [
            view.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor, constant: padding),
            view.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -padding),
            view.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: padding),
            view.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -padding)
        ]
    }

    class func height2WidthCardRatio(for view: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute:
            .height, relatedBy: .equal, toItem: view, attribute:
            .width, multiplier: .cardRatio, constant: 0)
    }
}
