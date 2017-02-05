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
    fileprivate let preview: PreviewOutline = PreviewOutline.constrained()
    fileprivate let background: UIImageView = UIImageView.constrained()
    fileprivate let backgroundEffect: UIVisualEffectView = UIVisualEffectView(effect:
        UIBlurEffect(style: .dark)).with { $0.translatesAutoresizingMaskIntoConstraints = false }
    fileprivate let scrollView: UIScrollView = UIScrollView.constrained()
    fileprivate let imageView: UIImageView = UIImageView.constrained()

    init(image: UIImage, side: Card.Side) {
        imageView.image = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)
        background.image = imageView.image
        self.side = side
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.closeButton.tapped = { [unowned self] in
            self.dismiss()
        }
        preview.captureButton.tapped = { [unowned self] in
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
        view.addSubview(background)
        view.addSubview(backgroundEffect)
        view.addSubview(preview)
        preview.outline.addSubview(scrollView)
        scrollView.addSubview(imageView)
    }

    private func configureViews() {
        view.clipsToBounds = true
        background.contentMode = .scaleAspectFill
        imageView.contentMode = .center
        preview.outline.clipsToBounds = true
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.contentSize = imageView.intrinsicContentSize
        let rotate = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        preview.captureButton.transform = rotate
        preview.closeButton.transform = rotate
    }

    fileprivate func configureConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.filledInSuperview(preview)
        constraints += NSLayoutConstraint.filledInSuperview(scrollView)
        constraints += NSLayoutConstraint.filledInSuperview(background)
        constraints += NSLayoutConstraint.filledInSuperview(backgroundEffect)
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.sizeToFit()
        let w = preview.outline.frame.width / imageView.frame.width
        let h = preview.outline.frame.height / imageView.frame.height
        let scale = max(w, h)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scrollView.minimumZoomScale
        let o = (scrollView.contentSize.width*scale-scrollView.frame.width)/2
        scrollView.contentInset = UIEdgeInsets(top: 0, left: -o, bottom: 0, right: o)
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

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.contentInset = UIEdgeInsets()
    }
}
