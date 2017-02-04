//
//  UICollectionView+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 04/02/17.
//

import UIKit

extension UICollectionView {
    class func makeCollectionView(in rect: CGRect) -> UICollectionView {
        let collectionView = UICollectionView(frame:
            .zero, collectionViewLayout: UICollectionViewFlowLayout.makeFlowLayout(in: rect))
        collectionView.backgroundColor = .clear
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: String(describing: CardCell.self))
        collectionView.alpha = 0.0
        return collectionView
    }
}

extension UICollectionViewFlowLayout {
    class func makeFlowLayout(in rect: CGRect) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let offset: CGFloat = 20
        let width = rect.size.width - 2 * offset
        layout.itemSize = CGSize(width: width, height: width / .cardRatio)
        layout.sectionInset = UIEdgeInsets(top: 4.25*offset, left: offset, bottom: offset, right: offset)
        layout.minimumInteritemSpacing = offset
        layout.minimumLineSpacing = offset

        return layout
    }
}
