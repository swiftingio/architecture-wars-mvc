//
//  CardMO+CoreDataClass.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 07/12/16.
//

import Foundation
import CoreData
import UIKit

public class CardMO: NSManagedObject {}

extension CardMO: ManagedObjectProtocol {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }

    func toEntity() -> Card? {
        var front: UIImage?
        var back: UIImage?
        self.front.map { front = UIImage(data: $0 as Data) }
        self.back.map { back = UIImage(data: $0 as Data) }
        return Card(identifier: identifier, name: name, front: front, back: back)
    }
}

extension Card: ManagedObjectConvertible {
    func toManagedObject(in context: NSManagedObjectContext) -> CardMO? {
        let card = CardMO.getOrCreateSingle(with: identifier, from: context)
        card.name = name
        card.identifier = identifier
        front.flatMap(UIImagePNGRepresentation).flatMap {
            card.front = NSData(data: $0)
        }
        back.flatMap(UIImagePNGRepresentation).flatMap {
            card.back = NSData(data: $0)
        }
        return card
    }
}
