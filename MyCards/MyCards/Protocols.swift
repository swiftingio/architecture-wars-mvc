//
//  Protocols.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 11/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

protocol IndexedCell {
    var indexPath: IndexPath? { get set }
}
protocol IndexedCellDelegate: class {
    func cellWasTapped(_ cell: IndexedCell)
}
