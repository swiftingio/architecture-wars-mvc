//
//  Result.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//

import UIKit

enum ResultError: Error {
    case noValue
}

enum Result<T> {
    case success(T)
    case failure(Error)
}

func ==<T: Equatable> (lhs: Result<T>, rhs: Result<T>) -> Bool {
    switch (lhs, rhs) {
    case (.success(let lhss), .success(let rhss)):
        return lhss == rhss

    case (.failure, .failure):
        return true

    default:
        return false
    }
}
