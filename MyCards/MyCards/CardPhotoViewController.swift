//
//  CardPhotoViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 04/12/16.
//

import UIKit

final class CardPhotoViewController: LightStatusBarViewController {

    fileprivate lazy var imageView: UIImageView = UIImageView(frame: .zero).with {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.alpha = 0
    }
    fileprivate lazy var backgroundImageView: UIImageView = UIImageView(frame: .zero).with {
        $0.contentMode = .scaleAspectFill
    }
    fileprivate lazy var backgroundEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate lazy var closeButton: CloseButton = CloseButton(frame: .zero).with {
        $0.alpha = 0
        $0.tapped = { [unowned self] in self.dismiss() }
    }

    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)
        backgroundImageView.image = imageView.image
        modalTransitionStyle = .crossDissolve
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
        view.addSubview(backgroundEffectView)
        view.addSubview(imageView)
        view.addSubview(closeButton)
    }

    private func configureConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = NSLayoutConstraint.filledInSuperview(backgroundImageView)
        constraints.append(contentsOf: NSLayoutConstraint.filledInSuperview(backgroundEffectView))
        constraints.append(contentsOf: NSLayoutConstraint.centeredInSuperview(imageView))
        constraints.append(NSLayoutConstraint.height2WidthCardRatio(for: imageView))
        constraints.append(closeButton.heightAnchor.constraint(equalToConstant: 40))
        constraints.append(closeButton.widthAnchor.constraint(equalToConstant: 40))
        constraints.append(closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20))
        constraints.append(closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        constraints.append(imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .cardOffsetY))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.cardOffsetY))
        NSLayoutConstraint.activate(constraints)
    }
}
