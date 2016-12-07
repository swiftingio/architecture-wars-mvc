//
//  CardMO+CoreDataProperties.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 07/12/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//  This file was automatically generated and should not be edited.
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
