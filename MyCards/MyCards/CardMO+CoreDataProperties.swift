//
//  CardMO+CoreDataProperties.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 07/12/16.
//

import Foundation
import CoreData

extension CardMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardMO> {
        return NSFetchRequest<CardMO>(entityName: "CardMO")
    }

    @NSManaged public var front: NSData?
    @NSManaged public var back: NSData?
    @NSManaged public var name: String
    @NSManaged public var identifier: String

}
