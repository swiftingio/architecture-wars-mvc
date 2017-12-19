//
//  PhotoCaptureViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 22/11/16.
//

import UIKit
import AVFoundation

protocol PhotoCaptureViewControllerDelegate: class {
    func photoCaptureViewController(_ viewController: PhotoCaptureViewController, didTakePhoto
        photo: UIImage, for side: Card.Side)
}

final class PhotoCaptureViewController: LightStatusBarViewController {

    weak var delegate: PhotoCaptureViewControllerDelegate?
    fileprivate let side: Card.Side
    fileprivate lazy var previewView: PreviewView = PreviewView().with {
        $0.session = self.session
        $0.captureButton.tapped = { [unowned self] in self.takePhoto() }
        $0.closeButton.tapped = { [unowned self] in self.dismiss() }
        $0.controlsAlpha = 0.0
        //display preview items in landscape right
        $0.captureButton.transform = .rotateRight
        $0.closeButton.transform = .rotateRight
    }

    // MARK: AVFoundation components
    fileprivate let output = AVCapturePhotoOutput().with {
        $0.isHighResolutionCaptureEnabled = true
        $0.isLivePhotoCaptureEnabled = false
    }
    fileprivate let session = AVCaptureSession()
    fileprivate let queue = DispatchQueue(label: "AV Session Queue", attributes: [], target: nil)
    fileprivate var authorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }

    init(side: Card.Side) {
        self.side = side
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        configureConstraints()
        requestAuthorizationIfNeeded()
        configureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
            self.previewView.controlsAlpha = 1.0
        }
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
    }

    fileprivate func configureConstraints() {

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let constraints: [NSLayoutConstraint] = NSLayoutConstraint.filledInSuperview(previewView)

        NSLayoutConstraint.activate(constraints)
    }

    fileprivate func requestAuthorizationIfNeeded() {
        guard .notDetermined == authorizationStatus else { return }
        queue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            guard granted else { return }
            self.queue.resume()
        }
    }

    fileprivate enum Error: Swift.Error {
        case noCamera
        case cannotAddInput
    }

    fileprivate func configureSession() {
        queue.async {
            guard .authorized == self.authorizationStatus else { return }
            guard let camera: AVCaptureDevice = AVCaptureDevice.backVideoCamera else { return }

            defer { self.session.commitConfiguration() }

            self.session.beginConfiguration()
            self.session.sessionPreset = AVCaptureSession.Preset.photo

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                guard self.session.canAddInput(input) else { return }
                self.session.addInput(input)
            } catch { return }

            guard self.session.canAddOutput(self.output) else { return }
            self.session.addOutput(self.output)
        }
    }

    fileprivate func takePhoto() {
        queue.async { [unowned self] in
            let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
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
}

extension PhotoCaptureViewController: AVCapturePhotoCaptureDelegate {

    // codebeat:disable[ARITY]
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Swift.Error?) {
        guard error == nil,
            let data = photo.fileDataRepresentation(),
            let photo = process(data)
            else { print("Error capturing photo: \(String(describing: error))"); return }

        delegate?.photoCaptureViewController(self, didTakePhoto: photo, for: side)
    }
    // codebeat:enable[ARITY]

    private func process(_ data: Data) -> UIImage? {
        guard let image = UIImage(data: data)?.cgImage else { return nil }
        let outline = previewView.outline.frame
        let outputRect = previewView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: outline)
        return cropp(image, to: outline, with: outputRect)
    }

    func cropp(_ image: CGImage, to outline: CGRect, with metadataOutputRect: CGRect) -> UIImage? {

        let originalSize: CGSize = CGSize(width: image.width, height: image.height)

        //NOTE: Scale using corresponding CGRect from AVCaptureVideoPreviewLayer
        let scaledOutline: CGSize = CGSize(width:
            originalSize.width * metadataOutputRect.width,
            height: CGFloat(image.height) * metadataOutputRect.height)

        //NOTE: Calculate card outline offset (x,y)
        let x: CGFloat = originalSize.width * metadataOutputRect.origin.x
        let y: CGFloat = originalSize.height * metadataOutputRect.origin.y

        let rect = CGRect(x: x,
                          y: y,
                          width: scaledOutline.width,
                          height: scaledOutline.height)

        guard let cropped = image.cropping(to: rect) else { return nil }

        let photo = UIImage(cgImage: cropped, scale: 1, orientation: .up)
        return photo
    }
}
