//
//  UIViewController+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 04/12/16.
//

import UIKit

extension UIViewController {
    func dismiss() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}
