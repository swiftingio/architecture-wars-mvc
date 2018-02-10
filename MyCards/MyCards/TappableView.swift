//
//  TappableView.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 13/11/16.
//

import UIKit

struct AnimationState {
    var performed: Bool = false
    var restoration: CGAffineTransform = .identity
}

class TappableView: UIView {

    fileprivate var touchingDownInside: Bool = false
    fileprivate let dimmedView: UIView
    fileprivate var animationState = AnimationState()
    let contentView: UIView
    var tapped: (() -> Void)?

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
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
        touchingDownInside = boundsContain(touches)
        if touchingDownInside {
            animateTap()
        }
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if !boundsContain(touches) {
            touchingDownInside = false
            undoTapAnimation()
        }
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
        clipsToBounds = true
    }

    fileprivate func configureConstraints() {
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf: NSLayoutConstraint.filledInSuperview(contentView))
        constraints.append(contentsOf: NSLayoutConstraint.filledInSuperview(dimmedView))
        NSLayoutConstraint.activate(constraints)
    }
}

extension TappableView {
    fileprivate func touchesUp(_ touches: Set<UITouch>? = nil) {
        undoTapAnimation()
        if touchingDownInside {
            tapped?()
        }
        touchingDownInside = false
    }

    fileprivate func boundsContain(_ touches: Set<UITouch>) -> Bool {
        for touch in touches {
            let location: CGPoint = touch.location(in: self)
            if bounds.contains(location) { return true }
        }
        return false
    }

    fileprivate func animateTap() {
        guard !animationState.performed else { return }
        animationState.performed = true
        animationState.restoration = transform
        UIView.animate(withDuration: 0.2) {
            let scale: CGFloat = 0.8
            self.transform = self.animationState.restoration.concatenating(CGAffineTransform(scaleX: scale, y: scale))
            self.dimmedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
    }

    fileprivate func undoTapAnimation() {
        guard animationState.performed else { return }
        animationState.performed = false
        UIView.animate(withDuration: 0.2) {
            self.transform = self.animationState.restoration
            self.dimmedView.backgroundColor = nil
        }
        animationState.restoration = .identity
    }
}
