//
//  CropViewConttroller.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 09/12/16.
//

import UIKit

protocol CropViewControllerDelegate: class {
    func cropViewController(_ viewController: CropViewController, didCropPhoto photo: UIImage)
}

class CropViewController: HiddenStatusBarViewController {

    weak var delegate: CropViewControllerDelegate?
    fileprivate let outline: UIView = UIView(frame: .zero).with { view in
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
    }
    fileprivate let imageView: UIImageView = UIImageView(frame: .zero)
    fileprivate let scrollView: UIScrollView = UIScrollView(frame: .zero)
    fileprivate let closeButton = CloseButton(frame: .zero)
    fileprivate let backgroundImageView: UIImageView = UIImageView(frame: .zero)
    fileprivate let visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let  captureButton = PhotoCameraButton(frame: .zero)

    init(image: UIImage) {
        imageView.image = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)
        backgroundImageView.image = imageView.image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.tapped = { [unowned self] in
            self.dismiss()
        }
        captureButton.tapped = { [unowned self] in
            self.process().flatMap {
                self.delegate?.cropViewController(self, didCropPhoto: $0)
            }
            self.dismiss()
        }
        addSubviews()
        configureViews()
        configureConstraints()
    }

    private func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(visualEffectView)
        view.addSubview(outline)
        outline.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(closeButton)
        view.addSubview(captureButton)
    }

    private func configureViews() {
        view.clipsToBounds = true
        backgroundImageView.contentMode = .scaleAspectFill
        imageView.contentMode = .center
        outline.clipsToBounds = true
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.contentSize = imageView.intrinsicContentSize
        let rotate = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        captureButton.transform = rotate
        closeButton.transform = rotate
    }

    fileprivate func configureConstraints() {

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let views: [String: Any] = [
            "closeButton": closeButton,
            "outline": outline,
            "photoButton": captureButton,
            ]

        let metrics: [String: CGFloat]  = [
            "photoButtonHeight": 80,
            "photoButtonWidth": 60,
            "padding": 20,
            "closeButtonHeight": 40,
            "closeButtonWidth": 40,
            "outlinePadX": .cardOffsetX,
            "outlinePadY": .cardOffsetY,
            ]

        let visual = [
            "V:[photoButton(photoButtonWidth)]-(padding)-|",
            "H:[photoButton(photoButtonHeight)]",
            "V:|-(padding)-[closeButton(closeButtonHeight)]",
            "H:[closeButton(closeButtonWidth)]-(padding)-|",
            "H:|-(outlinePadY)-[outline]-(outlinePadY)-|",
            ]

        var constraints: [NSLayoutConstraint] = NSLayoutConstraint.centeredInSuperview(outline)
        constraints.append(NSLayoutConstraint.centeredHorizontallyInSuperview(captureButton))
        constraints += NSLayoutConstraint.filledInSuperview(scrollView)
        constraints.append(NSLayoutConstraint(item: outline, attribute:
            .height, relatedBy: .equal, toItem: outline, attribute:
            .width, multiplier: .cardRatio, constant: 0))
        constraints += NSLayoutConstraint.filledInSuperview(backgroundImageView)
        constraints += NSLayoutConstraint.filledInSuperview(visualEffectView)
        visual.forEach {
            constraints += NSLayoutConstraint.constraints(withVisualFormat: $0, options:
                [], metrics: metrics, views: views)
        }

        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.sizeToFit()
        let w = outline.frame.width / imageView.frame.width
        let h = outline.frame.height / imageView.frame.height
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
