//
//  CardPhotoViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 04/12/16.
//

import UIKit

final class CardPhotoViewController: HiddenStatusBarViewController {

    fileprivate let imageView: UIImageView = UIImageView(frame: .zero)
    fileprivate let backgroundImageView: UIImageView = UIImageView(frame: .zero)
    fileprivate let visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
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
        var constraints: [NSLayoutConstraint] = NSLayoutConstraint.filledInSuperview(backgroundImageView)
        constraints += NSLayoutConstraint.filledInSuperview(visualEffectView)
        constraints += NSLayoutConstraint.centeredInSuperview(imageView)
        constraints.append(NSLayoutConstraint.height2WidthCardRatio(for: imageView))
        constraints.append(closeButton.heightAnchor.constraint(equalToConstant: 40))
        constraints.append(closeButton.widthAnchor.constraint(equalToConstant: 40))
        constraints.append(closeButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20))
        constraints.append(closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
        constraints.append(imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30))
        NSLayoutConstraint.activate(constraints)
    }
}
