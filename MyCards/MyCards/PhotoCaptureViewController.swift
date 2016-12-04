//
//  PhotoCaptureViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 22/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit
import AVFoundation

protocol PhotoCaptureDelegate: class {
    func photoTaken(_ data: Data)
}

class PhotoCaptureViewController: UIViewController {

    weak var delegate: PhotoCaptureDelegate?
    fileprivate let previewView = PreviewView()
    fileprivate var statusBarHidden: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    //swiftlint:disable variable_name
    override var shouldAutorotate: Bool { return false }
    override var prefersStatusBarHidden: Bool { return statusBarHidden }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .fade }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    //swiftlint:enable variable_name

    // MARK: AVFoundation components
    fileprivate let output = AVCapturePhotoOutput()
    fileprivate let session = AVCaptureSession()
    fileprivate let queue = DispatchQueue(label: "AV Session Queue", attributes: [], target: nil)
    fileprivate var authorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        configureConstraints()
        requestAuthorizationIfNeeded()

        queue.async { self.configureSession() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePreviewAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopSession()
        super.viewWillDisappear(animated)
    }
}

extension PhotoCaptureViewController {

    fileprivate func configureViews() {
        view.addSubview(previewView)
        view.backgroundColor = .black
        previewView.session = session
        previewView.captureButton.tapped = { [unowned self] in self.takePhoto() }
        previewView.closeButton.tapped = { [unowned self] in self.dismiss() }
        previewView.controlsAlpha = 0.0
        //display preview items in landscape right
        let rotate = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        previewView.captureButton.transform = rotate
        previewView.closeButton.transform = rotate
    }

    fileprivate func configureConstraints() {

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let constraints: [NSLayoutConstraint] = NSLayoutConstraint.filledInSuperview(previewView)

        NSLayoutConstraint.activate(constraints)
    }

    fileprivate func requestAuthorizationIfNeeded() {
        guard .notDetermined == AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) else { return }
        queue.suspend()
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { [unowned self] granted in
            guard granted else { return }
            self.queue.resume()
        }
    }

    fileprivate enum Error: Swift.Error {
        case noCamera
        case cannotAddInput
    }

    fileprivate func configureSession() {
        guard .authorized == authorizationStatus else { return }
        guard let camera: AVCaptureDevice = AVCaptureDevice.backVideoCamera else { return }

        defer { session.commitConfiguration() }

        session.beginConfiguration()
        session.sessionPreset = AVCaptureSessionPresetPhoto

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            guard session.canAddInput(input) else { return }
            session.addInput(input)
        } catch { return }

        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.isHighResolutionCaptureEnabled = true
        output.isLivePhotoCaptureEnabled = false
    }

    fileprivate func takePhoto() {
        queue.async { [unowned self] in
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.flashMode = .auto
            photoSettings.isHighResolutionPhotoEnabled = true
            self.output.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    fileprivate func startSession() {
        queue.async {
            guard self.authorizationStatus == .authorized else { return }
            guard !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    fileprivate func stopSession() {
        queue.async {
            guard self.authorizationStatus == .authorized else { return }
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    fileprivate func animatePreviewAppearance () {
        UIView.animate(withDuration: 0.25) {
            self.statusBarHidden = true
            self.previewView.controlsAlpha = 1.0
        }
    }
}

extension PhotoCaptureViewController: AVCapturePhotoCaptureDelegate {

    //swiftlint:disable function_parameter_count
    //swiftlint:disable line_length
    @objc(captureOutput:didFinishProcessingPhotoSampleBuffer:previewPhotoSampleBuffer:resolvedSettings:bracketSettings:error:)
    func capture(_ captureOutput: AVCapturePhotoOutput,
                          didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
                          previewPhotoSampleBuffer: CMSampleBuffer?,
                          resolvedSettings: AVCaptureResolvedPhotoSettings,
                          bracketSettings: AVCaptureBracketedStillImageSettings?,
                          error: NSError?) {
        guard let sample = photoSampleBuffer,
            let photo = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:
                sample, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            else { print("Error capturing photo: \(error)"); return }
        //TODO: rotate, trim
        delegate?.photoTaken(photo)
    }
    //swiftlint:enable function_parameter_count
    //swiftlint:enable line_length

}
