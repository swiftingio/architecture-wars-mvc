//
//  Data+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 09/04/17.
//

import Foundation

extension Data {
    var JSONObject: Any? {
        return try? JSONSerialization.jsonObject(with: self)
    }
}
