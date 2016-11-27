//
//  CloseButton.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 23/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

class CloseButton: TappableView {

    let cross: UIView = UIView(frame: .zero).with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }

    override var bounds: CGRect {
        didSet {
            setCrossShape()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cross)
        NSLayoutConstraint.activate(NSLayoutConstraint.filledInSuperview(cross))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
    }

    func setCrossShape() {
        let rect = bounds
        let crossShape = CAShapeLayer()
        crossShape.path = rect.crossPath
        crossShape.strokeColor = UIColor.white.cgColor
        crossShape.lineWidth = 2.0
        crossShape.cornerRadius = rect.height/2.0
        cross.layer.mask = crossShape
    }
}
