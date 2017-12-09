//
//  Card.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
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

extension Card {
    var isValid: Bool {
        guard
            let _ = front,
            let _ = back,
            !name.isEmpty,
            !identifier.isEmpty
            else { return false }
        return true
    }
}

extension Card {
    //TODO: Codable
    enum JSONKey: String {
        case identifier, name, front, back
    }
    init?(json: [String: Any]) {
        guard let identifier = json[JSONKey.identifier.rawValue] as? String,
            let name = json[JSONKey.name.rawValue] as? String,
            let front = json[JSONKey.front.rawValue] as? String,
            let back = json[JSONKey.back.rawValue] as? String
            else { return nil }
        self.identifier = identifier
        self.name = name
        self.front = Data(base64Encoded: front).flatMap(UIImage.init(data:))
        self.back = Data(base64Encoded: back).flatMap(UIImage.init(data:))
    }
}
