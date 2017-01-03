//
//  UIImagePickerControllerSourceType+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 20/11/16.
//

import UIKit

extension UIImagePickerControllerSourceType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .camera: return .Camera
        case .photoLibrary: return .PhotoLibrary
        case .savedPhotosAlbum: return .SavedPhotosAlbum
        }
    }

    static let allSources: [UIImagePickerControllerSourceType] = [.camera, .photoLibrary, .savedPhotosAlbum]
}
