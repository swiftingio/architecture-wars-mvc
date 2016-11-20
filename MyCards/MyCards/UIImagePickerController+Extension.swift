//
//  UIImagePickerController+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 20/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

extension UIImagePickerController {
    class func availableImagePickerSources() -> [UIImagePickerControllerSourceType] {
        return UIImagePickerControllerSourceType.allSources.filter {
            UIImagePickerController.isSourceTypeAvailable($0)
        }
    }
}
