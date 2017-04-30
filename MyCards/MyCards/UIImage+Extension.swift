//
//  UIImage+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 30/04/17.
//

import UIKit

extension UIImage {

    func resized(to size: CGSize) -> UIImage? {
        let image = self
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        defer {
            UIGraphicsEndImageContext()
        }
        guard let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return newImage
    }
}
