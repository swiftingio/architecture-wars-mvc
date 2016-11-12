//
//  Result.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit


enum ResultError: Error {
    case noValue
}

enum Result<T> {
    case success(T)
    case failure(Error)

    init(optional value: T?, error: @autoclosure() -> Error) {
        self = value.map(Result.success) ?? .failure(error())
    }

    init(throwing value: @autoclosure() throws -> T) {
        do {
            self = .success(try value())
        } catch {
            self = .failure(error)
        }
    }

    var isSuccess: Bool {
        if case .success(_) = self {
            return true
        }
        return false
    }

    var optional: T? {
        if case .success(let value) = self {
            return value
        } else {
            return nil
        }
    }

    func forceValue() throws -> T {
        if case .success(let value) = self {
            return value
        } else {
            throw ResultError.noValue
        }
    }

    var error: Error? {
        if case .failure(let error) = self {
            return error
        } else {
            return nil
        }
    }
}


func ==<T: Equatable> (lhs: Result<T>, rhs: Result<T>) -> Bool {
    switch (lhs, rhs) {
    case (.success(let lhss), .success(let rhss)):
        return lhss == rhss

    case (.failure(_), .failure(_)):
        return true

    default:
        return false
    }
}


extension Result {
    func map<U>(_ transform: (T) -> U) -> Result<U> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    func flatMap<U>(_ transform: (T) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let value):
            return transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
