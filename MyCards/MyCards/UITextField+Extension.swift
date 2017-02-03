//
//  UITextField+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 03/02/17.
//  Copyright © 2017 Maciej Piotrowski. All rights reserved.
//

import UIKit

extension UITextField {
    class func makeNameField() -> UITextField {
        let name = UITextField()
        name.autocorrectionType = .no
        name.autocapitalizationType = .none
        name.placeholder = .EnterCardName
        name.returnKeyType = .done
        return name
    }
}
