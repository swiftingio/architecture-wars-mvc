//
//  Array+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//

import Foundation

extension Array {
        subscript(safe position: Index) -> Element? {
        // Thanks Mike Ash
        return (0..<count ~= position) ? self[position] : nil
    }
}
