//
//  String+Localized.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 12/11/16.
//

import Foundation

func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

extension String {
    static let MyCards = NSLocalizedString("My Cards", comment: "")
    static let AddNewCard = NSLocalizedString("Add new card", comment: "")
    static let CardDetails = NSLocalizedString("Card Details", comment: "")
    static let EnterCardName = NSLocalizedString("Enter card name", comment: "")
    static let Set = NSLocalizedString("Set", comment: "")
    static let frontPhoto = NSLocalizedString("front photo", comment: "")
    static let backPhoto = NSLocalizedString("back photo", comment: "")
    static let Camera = NSLocalizedString("Camera", comment: "")
    static let PhotoLibrary = NSLocalizedString("Photo Library", comment: "")
    static let SavedPhotosAlbum = NSLocalizedString("Saved Photos Album", comment: "")
    static let Cancel = NSLocalizedString("Cancel", comment: "")
    static let OK = NSLocalizedString("OK", comment: "")
    static let SelectCardPhoto = NSLocalizedString("Select Card Photo", comment: "")
    static let NoName = NSLocalizedString("No Name", comment: "")
}
