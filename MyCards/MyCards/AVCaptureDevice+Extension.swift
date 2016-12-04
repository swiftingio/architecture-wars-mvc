//
//  AVCaptureDevice+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 04/12/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    class var duoBackVideoCamera: AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withDeviceType:
            .builtInDuoCamera, mediaType: AVMediaTypeVideo, position: .back)
    }

    class var duoFrontVideoCamera: AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withDeviceType:
            .builtInDuoCamera, mediaType: AVMediaTypeVideo, position: .front)
    }

    class var wideAngleBackVideoCamera: AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withDeviceType:
            .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
    }

    class var wideAngleFrontVideoCamera: AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withDeviceType:
            .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
    }

    class var backVideoCamera: AVCaptureDevice? {
        return duoBackVideoCamera ?? wideAngleBackVideoCamera
    }
}
