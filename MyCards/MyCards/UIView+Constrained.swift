//
//  UIView+Constrained.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 05/02/17.
//

import UIKit

extension UIView {
    class func constrained() -> Self {
        let view = self.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
