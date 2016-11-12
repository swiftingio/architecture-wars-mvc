//
//  TappableView.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 13/11/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

protocol TappableViewDelegate: class {
    func tappableViewWasTapped(_ view: TappableView)
}

class TappableView: UIView {

    fileprivate var touchingDownInside: Bool = false
    fileprivate var alreadyTapped: Bool = false
    fileprivate var dimmedView: UIView!

    var contentView: UIView!
    weak var delegate: TappableViewDelegate?

    override init(frame: CGRect) {
        contentView = UILabel(frame: .zero)
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
        //TODO: hit test
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
        clipsToBounds = true
    }

    fileprivate func configureConstraints() {
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.fillInSuperview(contentView)
        constraints += NSLayoutConstraint.fillInSuperview(dimmedView)
        NSLayoutConstraint.activate(constraints)
    }
}

extension TappableView {
    fileprivate func touchesDown(_ touches: Set<UITouch>) {
        touchingDownInside = boundsContain(touches)
        if touchingDownInside {
            animateTap()
        } else {
            undoTapAnimation()
        }
    }

    fileprivate func touchesUp(_ touches: Set<UITouch>? = nil) {
        undoTapAnimation()
        if touchingDownInside {
            touchingDownInside = false
            delegate?.tappableViewWasTapped(self)
        }
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

        UIView.animate(withDuration: 0.2) {
            let scale: CGFloat = 0.8
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.dimmedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
    }

    fileprivate func undoTapAnimation() {
        guard alreadyTapped else { return }
        alreadyTapped = false

        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
            self.dimmedView.backgroundColor = nil
        }
    }
}
