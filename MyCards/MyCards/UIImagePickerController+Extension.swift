//
//  UIImagePickerController+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 20/11/16.
//

import UIKit

extension UIImagePickerController {
    class func availableImagePickerSources() -> [UIImagePickerControllerSourceType] {
        return UIImagePickerControllerSourceType.allSources.filter {
            UIImagePickerController.isSourceTypeAvailable($0)
        }
    }
}
