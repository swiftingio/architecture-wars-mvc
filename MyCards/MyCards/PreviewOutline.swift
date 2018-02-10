//
//  PreviewOutline.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 05/02/17.
//

import UIKit

class PreviewOutline: UIView {

    let captureButton = PhotoCameraButton.constrained()
    let closeButton = CloseButton.constrained()
    let outline: UIView = UIView.constrained().with { view in
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
    }
    var controlsAlpha: CGFloat = 1.0 {
        didSet {
            captureButton.alpha = controlsAlpha
            closeButton.alpha = controlsAlpha
            outline.alpha = controlsAlpha
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(outline)
        addSubview(captureButton)
        addSubview(closeButton)
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureConstraints() {
        var constraints: [NSLayoutConstraint] = NSLayoutConstraint.centeredInSuperview(outline)
        constraints.append(NSLayoutConstraint.centeredInSuperview(captureButton, with: .centerX))
        constraints.append(NSLayoutConstraint.height2WidthCardRatio(for: outline))
        constraints.append(captureButton.heightAnchor.constraint(equalToConstant: 54))
        constraints.append(captureButton.widthAnchor.constraint(equalToConstant: 72))
        constraints.append(closeButton.heightAnchor.constraint(equalToConstant: 40))
        constraints.append(closeButton.widthAnchor.constraint(equalToConstant: 40))
        constraints.append(captureButton.bottomAnchor.constraint(equalTo:
            safeAreaLayoutGuide.bottomAnchor, constant: -20))
        constraints.append(closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20))
        constraints.append(closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20))
        constraints.append(outline.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: .cardOffsetY))
        constraints.append(outline.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -.cardOffsetY))
        NSLayoutConstraint.activate(constraints)
    }
}
