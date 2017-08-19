//
//  CardParser.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 09/04/17.
//

import UIKit
//TODO: use codable
final class CardParser: Parser, JSONDataConverting {
    func parse(_ json: Any?) -> Any? { //[[String : Any]] -> [Card]
        guard let items = json as? [[String : Any]] else { return nil }
        var cards: [Card] = []
        for item in items {
            guard let card = Card(json: item) else { continue }
            cards.append(card)
        }
        return cards
    }

    func json(from object: Any) -> Data? {
        guard let cards = object as? [Card] else { return nil }
        var json: [[String : Any]] = []
        for card in cards {
            var dictionary: [String : Any] = [:]
            dictionary[Card.JSONKey.name.rawValue] = card.name
            dictionary[Card.JSONKey.identifier.rawValue] = card.identifier
            dictionary[Card.JSONKey.front.rawValue] = card.front
                .flatMap { UIImagePNGRepresentation($0) }
                .flatMap { $0.base64EncodedString() } ?? ""
            dictionary[Card.JSONKey.back.rawValue] = card.back
                .flatMap { UIImagePNGRepresentation($0) }
                .flatMap { $0.base64EncodedString() } ?? ""
            json.append(dictionary)
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return data
        } catch {
            print(String(describing: error))
        }
        return nil
    }
}
