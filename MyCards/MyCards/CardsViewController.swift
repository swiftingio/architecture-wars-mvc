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
//    let front: UIImage
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
    
    override init(frame: CGRect) {
        nameLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(nameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    func configureView() {
        view.backgroundColor = .red
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.bounds.size.width * 0.8, height: 200)
        let offset: CGFloat = 10
        layout.sectionInset = UIEdgeInsets(top: offset, left: offset, bottom: offset, right: offset)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubview(collectionView)
    }
    
    func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
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
        cell.backgroundColor = .blue
        cell.name = card.name
        return cell
    }
}

extension CardsViewController: UICollectionViewDelegate {}
