//
//  Protocols.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 11/11/16.
//

import Foundation

public protocol Builder {}
extension Builder {
    public func with(configure: (inout Self) -> Void) -> Self {
        var this = self
        configure(&this)
        return this
    }
}

extension NSObject: Builder {}
