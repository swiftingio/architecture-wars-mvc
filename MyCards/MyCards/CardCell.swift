//
//  CardCell.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell, IndexedCell {

    fileprivate let nameLabel: UILabel
    fileprivate let effectView: UIVisualEffectView
    fileprivate let backgroundImageView: UIImageView
    fileprivate let tappableView: TappableView

    weak var delegate: IndexedCellDelegate?
    var indexPath: IndexPath?
    var name: String? {
        set {
            nameLabel.text = newValue
            nameLabel.sizeToFit()
        }
        get {
            return nameLabel.text
        }
    }

    var image: UIImage? {
        set {
            backgroundImageView.image = newValue
        }
        get {
            return backgroundImageView.image
        }
    }

    override init(frame: CGRect) {
        nameLabel = UILabel(frame: .zero)
        backgroundImageView = UIImageView(frame: .zero)
        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        tappableView = TappableView(frame: .zero)
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        name = nil
        image = nil
        indexPath = nil
    }
}

extension CardCell {
    fileprivate func configureViews() {
        tappableView.contentView.addSubview(backgroundImageView)
        tappableView.contentView.addSubview(effectView)
        tappableView.contentView.addSubview(nameLabel)
        contentView.addSubview(tappableView)
        
        backgroundImageView.contentMode = .scaleAspectFill
        nameLabel.textColor = .white
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        tappableView.layer.cornerRadius = 10
        tappableView.delegate = self
    }

    fileprivate func configureConstraints() {
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        tappableView.contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.centerInSuperview(nameLabel)
        constraints += NSLayoutConstraint.fillInSuperview(effectView)
        constraints += NSLayoutConstraint.fillInSuperview(backgroundImageView)
        constraints += NSLayoutConstraint.fillInSuperview(tappableView)
        NSLayoutConstraint.activate(constraints)
    }
}

extension CardCell: TappableViewDelegate {
    func tappableViewWasTapped(_ view: TappableView) {
        delegate?.cellWasTapped(self)
    }
}
