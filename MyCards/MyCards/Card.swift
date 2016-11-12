//
//  Card.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

struct Card {
    let name: String
    let front: UIImage = #imageLiteral(resourceName: "card")
    let back: UIImage = #imageLiteral(resourceName: "card")
}

extension Card {
    //TODO: remove when needed
    static func testCards(_ limit: Int) -> [Card] {
        var c = [Card]()
        for i in 0...limit {
            c.append(Card(name: "My new card for \(i)"))
        }
        return c
    }
}
