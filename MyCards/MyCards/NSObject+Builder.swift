//
//  Protocols.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 11/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import Foundation

public protocol Builder {}
extension Builder {
    public func with(configure: (inout Self) -> ()) -> Self {
        var this = self
        configure(&this)
        return this
    }
}

extension NSObject: Builder {}
