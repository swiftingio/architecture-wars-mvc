//
//  NetworLoader+Shared.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 09/04/17.
//

import Foundation

extension NetworkLoader {
    static let shared: NetworkLoader = NetworkLoader(URL(string: "http://localhost:8000")!)
}
