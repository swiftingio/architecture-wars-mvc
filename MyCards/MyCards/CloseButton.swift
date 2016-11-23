//
//  CloseButton.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 23/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

class CloseButton: TappableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let x = UIView(frame: .zero)
        x.translatesAutoresizingMaskIntoConstraints = false
        x.backgroundColor = .darkerBlue
        contentView.addSubview(x)
        NSLayoutConstraint.activate(NSLayoutConstraint.filledInSuperview(x))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
    }
}
