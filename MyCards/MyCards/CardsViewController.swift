//
//  CardsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

struct Card {
    let name: String
    let front: UIImage = #imageLiteral(resourceName: "card")
    //    let back: UIImage
}

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
    private let imageView: UIImageView
    var image: UIImage? {
        set {
            imageView.image = newValue
        }
        get {
            return imageView.image
        }
    }
    private let effectView: UIVisualEffectView
    
    override init(frame: CGRect) {
        nameLabel = UILabel(frame: .zero)
        nameLabel.textColor = .white
        //        nameLabel.font = UIFont(
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        let blurEffect = UIBlurEffect(style: .light)
        //        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        effectView = UIVisualEffectView(effect: blurEffect)
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(effectView)
        contentView.addSubview(nameLabel)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 1
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureConstraints() {
        let offset: CGFloat = 20
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(NSLayoutConstraint(item: nameLabel, attribute: .centerX, relatedBy: .equal, toItem: nameLabel.superview!, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: nameLabel.superview!, attribute: .top, multiplier: 1, constant: offset))
        
        let views: [String : Any] = [
            "effectView" : effectView,
            "imageView" : imageView
        ]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[effectView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[effectView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
    }
}

class CardsViewController: UIViewController {
    
    fileprivate let worker: CoreDataWorkerProtocol
    fileprivate var cards: [Card] = [Card(name: "Card 1"),
                                     Card(name: "Card 2"),
                                     Card(name: "Card 3"),
                                     Card(name: "Card 4"),
                                     Card(name: "Card 5"),
                                     Card(name: "Card 6"),
                                     Card(name: "Card 7"),
                                     Card(name: "Card 8"),
                                     ]
    fileprivate var collectionView: UICollectionView!
    fileprivate let reuseIdentifier: String = String(describing: CardCell.self)
    
    init(worker: CoreDataWorkerProtocol) {
        self.worker = worker
        super.init(nibName: nil, bundle: nil)
        self.title = "Cards"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationItem()
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    func configureView() {
        view.backgroundColor = . white
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.bounds.size.width * 0.8, height: 200)
        let offset: CGFloat = 20
        layout.sectionInset = UIEdgeInsets(top: offset, left: offset, bottom: offset, right: offset)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubview(collectionView)
    }
    
    func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    func configureConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        
        let views: [String : Any] = [
            "collectionView" : collectionView,
            ]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
        
    }
    func addTapped(sender: UIBarButtonItem) {
        showDetails(for: nil)
    }
    
    func showDetails(for card: Card?) {
        let viewController = CardDetailsViewController(card: card)
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
}

extension CardsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //TODO: safe
        
        let card = cards[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! CardCell
        cell.name = card.name
        cell.image = card.front
        return cell
    }
}

extension CardsViewController: UICollectionViewDelegate {}
