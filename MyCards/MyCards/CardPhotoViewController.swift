//
//  CardPhotoViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 04/12/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

final class CardPhotoViewController: UIViewController {
    fileprivate let imageView: UIImageView = UIImageView(frame: .zero)
    fileprivate let closeButton = CloseButton(frame: .zero)

    init(image: UIImage) {
        imageView.image = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }

    private func configureViews() {
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(closeButton)
        closeButton.tapped = { [unowned self] in self.dismiss() }
    }

    private func configureConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let views: [String: Any] = [
            "closeButton": closeButton,
            ]

        let metrics: [String: CGFloat]  = [
            "padding":20,
            "closeButtonHeight": 40,
            "closeButtonWidth": 40,
            ]

        let visual = [
            "V:|-(padding)-[closeButton(closeButtonHeight)]",
            "H:[closeButton(closeButtonWidth)]-(padding)-|",
            ]

        var constraints: [NSLayoutConstraint] = NSLayoutConstraint.filledInSuperview(imageView)
        visual.forEach {
            constraints += NSLayoutConstraint.constraints(withVisualFormat: $0, options:
                [], metrics: metrics, views: views)
        }

        NSLayoutConstraint.activate(constraints)
    }
}
