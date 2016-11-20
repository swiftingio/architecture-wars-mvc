//
//  String+Localized.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 12/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import Foundation

func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

extension String {
    static let MyCards = NSLocalizedString("My Cards")
    static let AddNewCard = NSLocalizedString("Add new card")
    static let EnterCardName = NSLocalizedString("Enter card name")
    static let Set = NSLocalizedString("Set")
    static let frontPhoto = NSLocalizedString("front photo")
    static let backPhoto = NSLocalizedString("back photo")
    static let Camera = NSLocalizedString("Camera")
    static let PhotoLibrary = NSLocalizedString("Photo Library")
    static let SavedPhotosAlbum = NSLocalizedString("Saved Photos Album")
    static let Cancel = NSLocalizedString("Cancel")
    static let OK = NSLocalizedString("OK")
}
