//
//  Card.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//

import UIKit

struct Card: Codable {
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
            front != nil,
            back != nil,
            !name.isEmpty,
            !identifier.isEmpty
            else { return false }
        return true
    }
}

extension Card {
    enum CodingKeys: String, CodingKey {
        case identifier, name, front, back
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        identifier = try container.decode(String.self, forKey: .identifier)

        let front = try container.decode(String.self, forKey: .front)
        let back = try container.decode(String.self, forKey: .back)
        self.front = Data(base64Encoded: front).flatMap(UIImage.init(data:))
        self.back = Data(base64Encoded: back).flatMap(UIImage.init(data:))
    }

    func encode(to encoder: Encoder) throws {
        var container =  encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(identifier, forKey: .identifier)
        let front: String = self.front
            .flatMap { UIImagePNGRepresentation($0) }
            .flatMap { $0.base64EncodedString() } ?? ""
        try container.encode(front, forKey: .front)
        let back: String = self.back
            .flatMap { UIImagePNGRepresentation($0) }
            .flatMap { $0.base64EncodedString() } ?? ""
        try container.encode(back, forKey: .back)
    }
}
