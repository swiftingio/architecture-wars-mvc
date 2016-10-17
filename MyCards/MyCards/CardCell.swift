//
//  CardCell.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    private let nameLabel: UILabel
    var name: String? {
        set {
            nameLabel.text = newValue
            nameLabel.sizeToFit()
        }
        get {
            return nameLabel.text
        }
    }
    private let backgroundImageView: UIImageView
    private let frontImageView: UIImageView
    private let backImageView: UIImageView
    var front: UIImage? {
        set {
            backgroundImageView.image = newValue
            frontImageView.image = newValue
        }
        get {
            return backgroundImageView.image
        }
    }
    var back: UIImage? {
        set {
            backImageView.image = newValue
        }
        get {
            return backImageView.image
        }
    }
    private let effectView: UIVisualEffectView
    
    override init(frame: CGRect) {
        nameLabel = UILabel(frame: .zero)
        nameLabel.textColor = .white
        //        nameLabel.font = UIFont(
        backgroundImageView = UIImageView(frame: .zero)
        backgroundImageView.contentMode = .scaleAspectFill
        
        frontImageView = UIImageView(frame: .zero)
        backImageView = UIImageView(frame: .zero)
        let blurEffect = UIBlurEffect(style: .light)
        //        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        effectView = UIVisualEffectView(effect: blurEffect)
        super.init(frame: frame)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(effectView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(frontImageView)
        contentView.addSubview(backImageView)
        
        
        frontImageView.layer.cornerRadius = 5
        frontImageView.clipsToBounds = true
        frontImageView.layer.cornerRadius = 5
        frontImageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        frontImageView.layer.borderWidth = 1
        frontImageView.contentMode = .scaleAspectFill
        
        backImageView.layer.cornerRadius = 5
        backImageView.clipsToBounds = true
        backImageView.layer.cornerRadius = 5
        backImageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        backImageView.layer.borderWidth = 1
        backImageView.contentMode = .scaleAspectFill
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        layer.cornerRadius = 10
        //        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        //        layer.borderWidth = 1
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureConstraints() {
        
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(NSLayoutConstraint(item: nameLabel, attribute: .centerX, relatedBy: .equal, toItem: nameLabel.superview!, attribute: .centerX, multiplier: 1, constant: 0))
        
        let views: [String : Any] = [
            "nameLabel" : nameLabel,
            "effectView" : effectView,
            "imageView" : backgroundImageView,
            "front" : frontImageView,
            "back" : backImageView,
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
            ("H:|-(==left)-[front]-(==mid)-[back(==front)]-(==right)-|", [.alignAllCenterY, .alignAllBottom, .alignAllTop]),
            ("V:|-(==top)-[nameLabel(==labelHeight)]-(==mid)-[front]-(==bottom)-|", .none),
            ("V:|[effectView]|", .none),
            ("H:|[effectView]|", .none),
            ("V:|[imageView]|", .none),
            ("H:|[imageView]|", .none),
            ]
        
        configurtion.forEach { (format, options) in
            constraints += NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: metrics, views: views)
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    /*
    func tappingOn(completion: (() -> Void)?) {
        if isPressing == true { return }
        isPressing = true
        if animationEnabled == false { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: self.minimalScale, y: self.minimalScale)
            self.restorationBackgroundColor = self.contentView.backgroundColor
            self.contentView.backgroundColor = self.highlightColor
        }) { (finished) in
            completion?()
        }
    }
    
    internal func tappingOff(completion: (() -> Void)?) {
        if isPressing == false { return }
        isPressing = false
        if animationEnabled == false { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.backgroundColor = self.restorationBackgroundColor
            self.contentView.transform = CGAffineTransform.identity
        }) { (finished) in
            completion?()
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if enabled == false { return }
        if isAnyOfThoseTouchesIsInTheBounds(touches: touches) {
            tappingOn(completion: nil)
            isCandidateForTap = true
        } else {
            tappingOff(completion: nil)
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if enabled == false { return }
        if isAnyOfThoseTouchesIsInTheBounds(touches: touches) {
            tappingOn(completion: nil)
            isCandidateForTap = true
        } else {
            tappingOff(completion: nil)
            isCandidateForTap = false
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if enabled == false { return }
        tappingOff(completion: nil)
        if isCandidateForTap == true {
            isCandidateForTap = false
            delegate?.buttonTapped(sender: self)
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if enabled == false { return }
        tappingOff(completion: nil)
        isCandidateForTap = false
    }
    
    func isAnyOfThoseTouchesIsInTheBounds(touches: Set<UITouch>) -> Bool {
        for touch in touches {
            let location: CGPoint = touch.location(in: self)
            if bounds.contains(location) { return true }
        }
        return false
    }
 */
}
