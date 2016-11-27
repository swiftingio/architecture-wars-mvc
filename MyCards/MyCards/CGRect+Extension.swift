//
//  CGRect+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 27/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: origin.x + width/2, y: origin.y + height/2)
    }

    var crossPath: CGPath {
        let rect = self
        let x = rect.origin.x
        let y = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height
        let line = UIBezierPath()
        line.move(to: rect.origin)
        line.addLine(to: CGPoint(x: x+width, y: y+height))
        line.move(to: CGPoint(x: x+width, y: y))
        line.addLine(to: CGPoint(x: x, y: y+height))
        return line.cgPath
    }
}
