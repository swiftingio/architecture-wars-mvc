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
    fileprivate lazy var previewView: PreviewOutline = PreviewOutline.constrained().with {
        $0.outline.clipsToBounds = true
        $0.captureButton.transform = .rotateRight
        $0.closeButton.transform = .rotateRight
        $0.closeButton.tapped = { [unowned self] in
            self.dismiss()
        }
        $0.captureButton.tapped = { [unowned self] in
            self.process().flatMap {
                self.delegate?.cropViewController(self, didCropPhoto: $0, for: self.side)
            }
            self.dismiss()
        }
    }
    fileprivate lazy var backgroundView: UIImageView = UIImageView.constrained().with {
        $0.contentMode = .scaleAspectFill
    }
    fileprivate let backgroundEffectView: UIVisualEffectView = UIVisualEffectView(effect:
        UIBlurEffect(style: .dark)).with { $0.translatesAutoresizingMaskIntoConstraints = false }
    fileprivate lazy var imageView: UIImageView = UIImageView(frame: .zero).with {
        $0.contentMode = .center
    }
    fileprivate lazy var scrollView: UIScrollView = UIScrollView.constrained().with {
        $0.delegate = self
        $0.maximumZoomScale = 2
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = true
    }

    init(image: UIImage, side: Card.Side) {
        self.side = side
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)
        backgroundView.image = imageView.image
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }

    private func configureViews() {
        view.clipsToBounds = true
        view.addSubview(backgroundView)
        view.addSubview(backgroundEffectView)
        view.addSubview(previewView)
        previewView.outline.addSubview(scrollView)
        scrollView.addSubview(imageView)
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

    fileprivate func process() -> UIImage? {
        guard let image = imageView.image?.cgImage else { return nil }

        let scale = scrollView.zoomScale
        let x = scrollView.bounds.origin.y
        let y = -scrollView.bounds.origin.x - scrollView.bounds.width + scrollView.contentSize.width
        let height = scrollView.bounds.height
        let width = scrollView.bounds.width
        let rect = CGRect(x: x / scale,
                          y: y / scale,
                          width: height / scale,
                          height: width / scale)

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
