//
//  CardParser.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 09/04/17.
//

import UIKit

final class CardParser: Parser, JSONDataConverting {

    func parse(_ json: Data, with decoder: JSONDecoder = JSONDecoder()) throws -> Any {
        let cards: [Card] = try decoder.decode([Card].self, from: json)
        return cards
    }

    func json(from object: Any) -> Data? {
        guard let cards = object as? [Card] else { return nil }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(cards)
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
