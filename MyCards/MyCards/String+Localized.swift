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
    static let EnterCardName = NSLocalizedString("Enter card name")
}
