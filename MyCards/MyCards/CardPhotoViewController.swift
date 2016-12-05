//
//  CardPhotoViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 04/12/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

final class CardPhotoViewController: HiddenStatusBarViewController {

    fileprivate let imageView: UIImageView = UIImageView(frame: .zero)
    fileprivate let backgroundImageView: UIImageView = UIImageView(frame: .zero)
    fileprivate let visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    fileprivate let closeButton = CloseButton(frame: .zero)

    init(image: UIImage) {
        imageView.image = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)
        backgroundImageView.image = imageView.image
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
            self.imageView.alpha = 1
            self.closeButton.alpha = 1
        }
    }

    private func configureViews() {
        view.backgroundColor = .black
        view.addSubview(backgroundImageView)
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(visualEffectView)
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.alpha = 0
        view.addSubview(closeButton)
        closeButton.alpha = 0
        closeButton.tapped = { [unowned self] in self.dismiss() }
    }

    private func configureConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let views: [String: Any] = [
            "closeButton": closeButton,
            "imageView": imageView,
            ]

        let metrics: [String: CGFloat]  = [
            "padding":20,
            "closeButtonHeight": 40,
            "closeButtonWidth": 40,
            "hPadding": 30,
            ]

        let visual = [
            "V:|-(padding)-[closeButton(closeButtonHeight)]",
            "H:[closeButton(closeButtonWidth)]-(padding)-|",
            "H:|-(hPadding)-[imageView]-(hPadding)-|",
            ]

        var constraints: [NSLayoutConstraint] = NSLayoutConstraint.filledInSuperview(backgroundImageView)
        constraints += NSLayoutConstraint.filledInSuperview(visualEffectView)
        constraints += NSLayoutConstraint.centeredInSuperview(imageView)
        constraints.append(NSLayoutConstraint(item: imageView, attribute:
            .height, relatedBy: .equal, toItem: imageView, attribute:
            .width, multiplier: .cardRatio, constant: 0))
        visual.forEach {
            constraints += NSLayoutConstraint.constraints(withVisualFormat: $0, options:
                [], metrics: metrics, views: views)
        }

        NSLayoutConstraint.activate(constraints)
    }
}
