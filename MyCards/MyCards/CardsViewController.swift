//
//  CardsViewController.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import UIKit

protocol IndexedCell {
    var indexPath: IndexPath? { get set }
}
protocol IndexedCellDelegate: class {
    func cellWasTapped(_ cell: IndexedCell)
}

// MARK: - Lifecycle
final class CardsViewController: UIViewController {

    fileprivate let worker: CoreDataWorkerProtocol
    fileprivate lazy var cards: [Card] = []

    fileprivate var emptyScreen: UIImageView!
    fileprivate var collectionView: UICollectionView!
    fileprivate let reuseIdentifier: String = String(describing: CardCell.self)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var shouldAutorotate: Bool { return false }

    init(worker: CoreDataWorkerProtocol = CoreDataWorker()) {
        self.worker = worker
        super.init(nibName: nil, bundle: nil)
        self.title = .MyCards
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        configureViews()
        configureConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //TODO: Fetched results controller?
        worker.get() {
            [weak self](result: Result<[Card]>) in
            switch result {
            case .failure(_): break
            case .success(let cards):
                self?.cards = cards
                self?.reloadData()
            }

        }
    }

    func reloadData() {
        if !cards.isEmpty {
            hideEmptyScreen()
        } else {
            showEmptyScreen()
        }
        collectionView.reloadData()
    }
}

// MARK: - Configuration
extension CardsViewController {

    fileprivate func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:
            .add, target: self, action: #selector(addTapped))
    }

    fileprivate func configureViews() {
        view.backgroundColor = . white

        emptyScreen = makeEmptyScreen()
        view.addSubview(emptyScreen)

        collectionView = makeCollectionView(in: view.bounds)
        view.addSubview(collectionView)
    }

    fileprivate func configureConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.centeredInSuperview(emptyScreen)
        constraints += NSLayoutConstraint.filledInSuperview(collectionView)
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Helpers
extension CardsViewController {

    fileprivate func makeFlowLayout(in rect: CGRect) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let offset: CGFloat = 20
        let width = rect.size.width - 2 * offset
        layout.itemSize = CGSize(width: width, height: width / .cardRatio)
        layout.sectionInset = UIEdgeInsets(top: 4.25*offset, left: offset, bottom: offset, right: offset)
        layout.minimumInteritemSpacing = offset
        layout.minimumLineSpacing = offset

        return layout
    }

    fileprivate func makeCollectionView(in rect: CGRect) -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeFlowLayout(in: rect))
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alpha = 0.0
        return collectionView
    }

    fileprivate func makeEmptyScreen() -> UIImageView {
        let emptyScreen = UIImageView(image: #imageLiteral(resourceName: "bluebird"))
        emptyScreen.alpha = cards.isEmpty ? 1.0 : 0.0
        return emptyScreen
    }

    fileprivate func hideEmptyScreen() {
        UIView.animate(withDuration: 0.2) {
            self.emptyScreen.alpha = 0.0
            self.collectionView.alpha = 1.0
        }
    }

    fileprivate func showEmptyScreen() {
        UIView.animate(withDuration: 0.2) {
            self.emptyScreen.alpha = 1.0
            self.collectionView.alpha = 0.0
        }
    }

    @objc fileprivate func addTapped(sender: UIBarButtonItem) {
        showDetails(of: nil)
    }

    fileprivate func showDetails(of card: Card?) {
        let viewController = CardDetailsViewController(card: card)
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }

}

// MARK: - UICollectionViewDataSource
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

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
            reuseIdentifier, for: indexPath) as? CardCell,
            let card = cards[safe: indexPath.row]
            else { return UICollectionViewCell() }

        //TODO: use smaller images / thumbnails
        cell.name = card.name
        cell.image = card.front ?? #imageLiteral(resourceName: "background")
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CardsViewController: UICollectionViewDelegate {}

// MARK: - IndexedCellDelegate
extension CardsViewController: IndexedCellDelegate {
    func cellWasTapped(_ cell: IndexedCell) {
        guard let indexPath = cell.indexPath,
            let card = cards[safe: indexPath.row] else { return }
        showDetails(of: card)
    }
}
