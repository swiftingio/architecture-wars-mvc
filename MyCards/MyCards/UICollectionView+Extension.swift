//
//  UICollectionView+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 04/02/17.
//

import UIKit

public extension UICollectionViewCell {
    public static var identifier: String { return String(describing: self) }
}

public extension UICollectionView {
    public func register(_ cell: UICollectionViewCell.Type) {
        register(cell, forCellWithReuseIdentifier: cell.identifier)
    }

    public func dequeueReusableCell<CellClass: UICollectionViewCell>(of class: CellClass.Type,
                                    for indexPath: IndexPath,
                                    configure: ((CellClass) -> Void) = { _ in }) -> UICollectionViewCell {

        let cell = dequeueReusableCell(withReuseIdentifier: CellClass.identifier,
                                       for: indexPath)

        if let typedCell = cell as? CellClass {
            configure(typedCell)
        }

        return cell
    }
}
