//
//  File.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 23/11/16.
//

import UIKit

class PhotoCameraButton: TappableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let camera = PhotoCamera(frame: .zero)
        camera.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(camera)
        NSLayoutConstraint.activate(NSLayoutConstraint.filledInSuperview(camera))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
