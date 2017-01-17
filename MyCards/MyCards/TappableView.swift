//
//  TappableView.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 13/11/16.
//

import UIKit

class TappableView: UIView {

    fileprivate var touchingDownInside: Bool = false
    fileprivate var forceTouchDownInside: Bool = false
    fileprivate var alreadyTapped: Bool = false
    fileprivate var dimmedView: UIView!
    fileprivate var label: UILabel!
    fileprivate var previousTransform: CGAffineTransform = .identity

    var tapped: (() -> Void)?
    var forceTapped: (() -> Void)?

    var contentView: UIView!

    var text: String? {
        set {
            label.text = newValue
        }
        get {
            return label.text
        }
    }
    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        label = UILabel(frame: .zero)
        contentView = UIView(frame: .zero)
        dimmedView = UIView(frame: .zero)
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesDown(touches)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touchesDown(touches)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesUp()
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchingDownInside = false
        touchesUp()
    }

    fileprivate func configureViews() {
        dimmedView.backgroundColor = nil
        addSubview(contentView)
        contentView.clipsToBounds = true
        addSubview(dimmedView)
        addSubview(label)
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.numberOfLines = 0
        clipsToBounds = true
    }

    fileprivate func configureConstraints() {
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.filledInSuperview(contentView)
        constraints += NSLayoutConstraint.filledInSuperview(dimmedView)
        constraints += NSLayoutConstraint.centeredInSuperview(label)
        NSLayoutConstraint.activate(constraints)
    }
}

extension TappableView {
    fileprivate func forceTouchAvailable() -> Bool {
        return traitCollection.forceTouchCapability == .available
    }
    fileprivate func touchesDown(_ touches: Set<UITouch>) {
        touchingDownInside = boundsContain(touches)
        if touchingDownInside {
            animateTap()
            if forceTouchAvailable(),
                let touch = touches.first {
                forceTouchDownInside = touch.force == touch.maximumPossibleForce
            }
        } else {
            undoTapAnimation()
        }
    }

    fileprivate func touchesUp(_ touches: Set<UITouch>? = nil) {
        undoTapAnimation()
        if forceTouchAvailable() && forceTouchDownInside {
            forceTapped?()
        } else if touchingDownInside {
            tapped?()
        }
        clearTouchDownInside()
    }

    fileprivate func clearTouchDownInside() {
        touchingDownInside = false
        forceTouchDownInside = false
    }

    fileprivate func boundsContain(_ touches: Set<UITouch>) -> Bool {
        for touch in touches {
            let location: CGPoint = touch.location(in: self)
            if bounds.contains(location) { return true }
        }
        return false
    }

    fileprivate func animateTap() {
        guard !alreadyTapped else { return }
        alreadyTapped = true
        previousTransform = transform
        UIView.animate(withDuration: 0.2) {
            let scale: CGFloat = 0.8
            self.transform = self.previousTransform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
            self.dimmedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
    }

    fileprivate func undoTapAnimation() {
        guard alreadyTapped else { return }
        alreadyTapped = false
        UIView.animate(withDuration: 0.2) {
            self.transform = self.previousTransform
            self.dimmedView.backgroundColor = nil
        }
        previousTransform = .identity
    }
}
