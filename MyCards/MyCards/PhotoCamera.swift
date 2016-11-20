//
//  PhotoButton.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 13/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

class PhotoCamera: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        // Main Shape
        let x = rect.origin.x
        let y = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height
        let radius: CGFloat = height / 10.0
        let main = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: width, height: height), cornerRadius: radius)
        UIColor.lightGray.setFill()
        main.fill()

        // Inner Shape
        let innerX: CGFloat = x
        let innerY: CGFloat = height * 5 / 30.0
        let innerWidth: CGFloat = width
        let innerHeight: CGFloat = height * 2 / 3.0
        let inner = UIBezierPath(rect: CGRect(x: innerX, y: innerY, width: innerWidth, height: innerHeight))
        UIColor.gray.setFill()
        inner.fill()

        // Viewfinder
        let viewFinderX: CGFloat = width / 16.0
        let viewFinderY: CGFloat = height / 12.0
        let viewFinderWidth: CGFloat = width / 6.0
        let viewFinderHeight: CGFloat = height / 6.0
        let viewFinderRadius: CGFloat = width / 10.0
        let viewfinder = UIBezierPath(roundedRect: CGRect(x: viewFinderX, y: viewFinderY, width:
            viewFinderWidth, height: viewFinderHeight), cornerRadius: viewFinderRadius)
        UIColor.lightBlue.setFill()
        viewfinder.fill()
        UIColor.darkerBlue.setStroke()
        viewfinder.lineWidth = 1
        viewfinder.stroke()

        // Lense cover
        let coverSide: CGFloat = height / (30.0 / 22.0)
        let coverX: CGFloat = width / 2.0 - coverSide / 2.0
        let coverY: CGFloat = height / 2.0 - coverSide / 2.0
        let cover = UIBezierPath(ovalIn: CGRect(x: coverX, y: coverY, width: coverSide, height: coverSide))
        UIColor.darkerBlue.setFill()
        cover.fill()

        // Lense
        let lenseSide: CGFloat = coverSide * 0.9
        let lenseX: CGFloat = width / 2.0 - lenseSide / 2.0
        let lenseY: CGFloat = height / 2.0 - lenseSide / 2.0
        let lense = UIBezierPath(ovalIn: CGRect(x: lenseX, y: lenseY, width: lenseSide, height: lenseSide))
        UIColor.lightBlue.setFill()
        lense.fill()
        alpha = 1.0
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        alpha = 0.0
        setNeedsDisplay()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 30)
    }
}
