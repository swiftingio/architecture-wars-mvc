//
//  CardCell.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell, IndexedCell {
    
    fileprivate let nameLabel: UILabel
    fileprivate let effectView: UIVisualEffectView
    fileprivate let backgroundImageView: UIImageView
    
    weak var delegate: IndexedCellDelegate?
    var indexPath: IndexPath?
    var name: String? {
        set {
            nameLabel.text = newValue
            nameLabel.sizeToFit()
        }
        get {
            return nameLabel.text
        }
    }
    
    var image: UIImage? {
        set {
            backgroundImageView.image = newValue
        }
        get {
            return backgroundImageView.image
        }
    }
    
    override init(frame: CGRect) {
        nameLabel = UILabel(frame: .zero)
        backgroundImageView = UIImageView(frame: .zero)
        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        name = nil
        image = nil
        indexPath = nil
    }
    
    fileprivate var touchDownInside: Bool = false
    fileprivate var alreadyTapped: Bool = false
}

extension CardCell {
    fileprivate func configureViews() {
        nameLabel.textColor = .white
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        backgroundImageView.contentMode = .scaleAspectFill
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(effectView)
        contentView.addSubview(nameLabel)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        layer.cornerRadius = 10
    }
    
    fileprivate func configureConstraints() {
        
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        let views: [String : Any] = [
            "nameLabel" : nameLabel,
            "effectView" : effectView,
            "imageView" : backgroundImageView,
            ]
        
        let metrics: [String : Any] = [
            "top" : 20,
            "mid" : 20,
            "left" : 10,
            "right": 10,
            "labelHeight" : 20,
            "bottom" : 40,
            ]
        
        let configurtion: [(String, NSLayoutFormatOptions)] = [
            ("V:|[effectView]|", .none),
            ("H:|[effectView]|", .none),
            ("V:|[imageView]|", .none),
            ("H:|[imageView]|", .none),
            ]
        
        var constraints: [NSLayoutConstraint] = []
        
        configurtion.forEach { (format, options) in
            constraints += NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: metrics, views: views)
        }
        
        constraints += NSLayoutConstraint.centerInSuperview(nameLabel)
        NSLayoutConstraint.activate(constraints)
    }
}

extension CardCell {
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
        touchDownInside = false
        touchesUp()
    }
}

extension CardCell {
    fileprivate func touchesDown(_ touches: Set<UITouch>) {
        touchDownInside = boundsContain(touches)
        if touchDownInside {
            animateTap()
        } else {
            undoTapAnimation()
        }
    }
    
    fileprivate func touchesUp(_ touches: Set<UITouch>? = nil) {
        undoTapAnimation()
        if touchDownInside {
            touchDownInside = false
            delegate?.cellWasTapped(self)
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
            let scale:CGFloat = 0.8
            self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.effectView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
    }
    
    fileprivate func undoTapAnimation() {
        guard alreadyTapped else { return }
        alreadyTapped = false
        
        UIView.animate(withDuration: 0.2) {
            self.contentView.transform = .identity
            self.effectView.backgroundColor = nil
        }
    }
}
