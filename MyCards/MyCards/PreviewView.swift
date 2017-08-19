//
//  PreviewView.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 23/11/16.
//

import UIKit
import AVFoundation

final class PreviewView: PreviewOutline {

    override init(frame: CGRect) {
        super.init(frame: frame)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        //swiftlint:disable force_cast
        return layer as! AVCaptureVideoPreviewLayer
        //swiftlint:enable force_cast
    }

    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
