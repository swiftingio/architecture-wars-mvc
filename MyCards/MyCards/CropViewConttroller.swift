//
//  CropViewConttroller.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 09/12/16.
//

import UIKit

protocol CropViewControllerDelegate: class {
    func cropViewController(_ viewController: CropViewController, didCropPhoto photo: UIImage, for side: Card.Side)
}

class CropViewController: HiddenStatusBarViewController {

    weak var delegate: CropViewControllerDelegate?
    fileprivate let side: Card.Side

    // MARK: Views
    fileprivate let previewView: PreviewOutline = PreviewOutline.constrained()
    fileprivate let backgroundView: UIImageView = UIImageView.constrained()
    fileprivate let backgroundEffectView: UIVisualEffectView = UIVisualEffectView(effect:
        UIBlurEffect(style: .dark)).with { $0.translatesAutoresizingMaskIntoConstraints = false }
    fileprivate let imageView: UIImageView = UIImageView(frame: .zero)
    fileprivate lazy var scrollView: UIScrollView = UIScrollView.constrained().with {
        $0.delegate = self
        $0.maximumZoomScale = 2
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = true
    }

    init(image: UIImage, side: Card.Side) {
        imageView.image = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)
        backgroundView.image = imageView.image
        self.side = side
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        previewView.closeButton.tapped = { [unowned self] in
            self.dismiss()
        }
        previewView.captureButton.tapped = { [unowned self] in
            self.process().flatMap {
                self.delegate?.cropViewController(self, didCropPhoto: $0, for: self.side)
            }
            self.dismiss()
        }
        addSubviews()
        configureViews()
        configureConstraints()
    }

    private func addSubviews() {
        view.addSubview(backgroundView)
        view.addSubview(backgroundEffectView)
        view.addSubview(previewView)
        previewView.outline.addSubview(scrollView)
        scrollView.addSubview(imageView)
    }

    private func configureViews() {
        view.clipsToBounds = true
        backgroundView.contentMode = .scaleAspectFill
        imageView.contentMode = .center
        previewView.outline.clipsToBounds = true
        let rotate = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        previewView.captureButton.transform = rotate
        previewView.closeButton.transform = rotate
    }

    fileprivate func configureConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.filledInSuperview(previewView)
        constraints += NSLayoutConstraint.filledInSuperview(scrollView)
        constraints += NSLayoutConstraint.filledInSuperview(backgroundView)
        constraints += NSLayoutConstraint.filledInSuperview(backgroundEffectView)
        NSLayoutConstraint.activate(constraints)
        previewView.layoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let w: CGFloat = previewView.outline.frame.width / CGFloat(imageView.image!.cgImage!.width)
        let h: CGFloat = previewView.outline.frame.height / CGFloat(imageView.image!.cgImage!.height)
        let scale = max(w, h)
        imageView.sizeToFit()
        scrollView.contentSize = imageView.bounds.size
        scrollView.contentOffset = CGPoint(x: imageView.bounds.width/2, y: imageView.bounds.height/2)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scrollView.minimumZoomScale
    }

    func process() -> UIImage? {
        guard let image = imageView.image?.cgImage else { return nil }
        // FIXME: scaling

        //original image size
//        let height: CGFloat = CGFloat(scrollView.contentSize.height)
//        let width: CGFloat = CGFloat(scrollView.contentSize.width)

        let scale = scrollView.zoomScale
        let height = scrollView.bounds.height
        let width = scrollView.bounds.width

        let rect = CGRect(x: scrollView.bounds.origin.x,
                          y: scrollView.bounds.origin.y,
                          width: width / scale,
                          height: height / scale)

        guard let cropped = image.cropping(to: rect) else { return nil }

        let photo = UIImage(cgImage: cropped, scale: 1, orientation: .up)
        return photo
    }
}

extension CropViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
