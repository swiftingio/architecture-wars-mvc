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
    let takePhotoButton: TappableView

    init(image: UIImage?) {
        imageView = UIImageView(frame: .zero)
        takePhotoButton = TappableView(frame: .zero)
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
        contentView.addSubview(takePhotoButton)

        imageView.contentMode = .scaleAspectFill
        let radius: CGFloat = 10
        layer.cornerRadius = radius
        takePhotoButton.isHidden = false
        takePhotoButton.backgroundColor = .red
        takePhotoButton.layer.cornerRadius = radius
//        takePhotoButton.delegate = self
    }

    fileprivate func configureConstraints() {
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: takePhotoButton, attribute: .height, relatedBy:
                .equal, toItem: takePhotoButton.superview!, attribute: .height, multiplier: 0.2, constant: 0),
            NSLayoutConstraint(item: takePhotoButton, attribute: .width, relatedBy:
                .equal, toItem: takePhotoButton.superview!, attribute: .width, multiplier: 0.2, constant: 0),
            NSLayoutConstraint(item: takePhotoButton, attribute: .top, relatedBy:
                .equal, toItem: takePhotoButton.superview!, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: takePhotoButton, attribute: .trailing, relatedBy:
                .equal, toItem: takePhotoButton.superview!, attribute: .trailing, multiplier: 1, constant: 0),
            ]
        constraints += NSLayoutConstraint.fillInSuperview(imageView)
        NSLayoutConstraint.activate(constraints)
    }
}
