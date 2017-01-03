//
//  CardCell.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//

import UIKit

class CardCell: UICollectionViewCell, IndexedCell {

    fileprivate let nameLabel: UILabel
    fileprivate let imageView: UIImageView
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
            imageView.image = newValue
        }
        get {
            return imageView.image
        }
    }

    override init(frame: CGRect) {
        nameLabel = UILabel(frame: .zero)
        imageView = UIImageView(frame: .zero)
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
        tappableView.contentView.addSubview(imageView)
        tappableView.contentView.addSubview(nameLabel)
        contentView.addSubview(tappableView)

        imageView.contentMode = .scaleAspectFill
        nameLabel.textColor = .white
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        tappableView.layer.cornerRadius = 10
        tappableView.tapped = { [unowned self] in self.tappableViewWasTapped() }
    }

    fileprivate func configureConstraints() {
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        tappableView.contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.centeredInSuperview(nameLabel)
        constraints += NSLayoutConstraint.filledInSuperview(imageView)
        constraints += NSLayoutConstraint.filledInSuperview(tappableView)
        NSLayoutConstraint.activate(constraints)
    }

    func tappableViewWasTapped() {
        delegate?.cellWasTapped(self)
    }
}
