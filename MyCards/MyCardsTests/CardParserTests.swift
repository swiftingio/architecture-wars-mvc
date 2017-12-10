//
//  CardParserTests.swift
//  MyCardsTests
//
//  Created by Paciej on 10/12/2017.
//

import XCTest
@testable import MyCards

class CardParserTests: XCTestCase {

    var parser: CardParser!
    override func setUp() {
        super.setUp()
        parser = CardParser()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    func testParsing() {
        do {
            let data = jsonDataFromMainBundle()
            if let cards: [Card] = try parser.parse(data) as? [Card],
                let card = cards.first {
                XCTAssertNotNil(cards)
                XCTAssertFalse(cards.isEmpty)
                XCTAssertEqual(card.name, .cardName)
                XCTAssertEqual(card.identifier, .cardIdentifier)
                XCTAssertNotNil(card.front)
                XCTAssertNotNil(card.back)
            } else {
                XCTFail("no card in json :(")
            }
        } catch {
            XCTFail("parser thrown an error: \(error)")
        }
    }

    func testConverting() {
        let front = UIImage(data: #imageLiteral(resourceName: "front").data!)
        let back = UIImage(data: #imageLiteral(resourceName: "back").data!)
        let card = Card(identifier: .cardIdentifier, name: .cardName, front: front, back: back)
        do {
            guard let jsonFromCard = parser.json(from: [card]),
                let cards = try parser.parse(jsonFromCard) as? [Card],
                let cardFromJSON = cards.first else {
                    XCTFail("parsing jSON failed")
                    return
            }
            XCTAssertNotNil(jsonFromCard)
            XCTAssertEqual(card, cardFromJSON)
        } catch {
            XCTFail("parser thrown an error: \(error)")
        }
    }
}

extension CardParserTests {
    func jsonDataFromMainBundle() -> Data {
        let bundle = Bundle(for: CardParser.self)
        guard let url = bundle.url(forResource: "cards", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
                XCTFail("cards.json not contained in a bundle!")
                return Data()
        }
        XCTAssertNotNil(data)
        return data
    }

    func write(_ data: Data, to file: String = "cards.json") -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                try data.write(to: fileURL)
                return fileURL
            } catch { /* error handling here */ }
        }
        return nil
    }
}
