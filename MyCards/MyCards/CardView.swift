//
//  CardView.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 12/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

class CardView: TappableView {

    fileprivate let imageView: UIImageView
    let photoCamera: PhotoCamera

    init(image: UIImage?) {
        imageView = UIImageView(frame: .zero)
        photoCamera = PhotoCamera(frame: .zero)
        super.init(frame: .zero)
        self.image = image
        configureViews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var image: UIImage? {
        set {
            imageView.image = newValue
            if newValue == nil {
                imageView.image = #imageLiteral(resourceName: "logo")
            }
        }
        get {
            return imageView.image
        }
    }
}

extension CardView {
    fileprivate func configureViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(photoCamera)

        imageView.contentMode = .scaleAspectFill
        let radius: CGFloat = 10
        layer.cornerRadius = radius
        photoCamera.isHidden = false
    }

    fileprivate func configureConstraints() {
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: photoCamera, attribute: .height, relatedBy:
                .equal, toItem: photoCamera.superview!, attribute: .height, multiplier: 0.2, constant: 0),
            NSLayoutConstraint(item: photoCamera, attribute: .width, relatedBy:
                .equal, toItem: photoCamera.superview!, attribute: .width, multiplier: 0.2, constant: 0),
            NSLayoutConstraint(item: photoCamera, attribute: .top, relatedBy:
                .equal, toItem: photoCamera.superview!, attribute: .top, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: photoCamera, attribute: .trailing, relatedBy:
                .equal, toItem: photoCamera.superview!, attribute: .trailing, multiplier: 1, constant: -10),
            ]
        constraints += NSLayoutConstraint.filledInSuperview(imageView)
        NSLayoutConstraint.activate(constraints)
    }

}
