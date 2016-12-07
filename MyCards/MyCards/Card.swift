//
//  Card.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

struct Card {
    let identifier: String
    let name: String
    let front: UIImage?
    let back: UIImage?

    init(identifier: String = UUID().uuidString,
         name: String,
         front: UIImage? = nil,
         back: UIImage? = nil) {
        self.identifier = identifier
        self.name = name
        self.front = front
        self.back = back
    }
}

extension Card {
    enum Side {
        case front
        case back
    }
}

extension Card.Side: CustomStringConvertible {
    var description: String {
        switch self {
        case .front: return .frontPhoto
        case .back: return .backPhoto
        }
    }
}
